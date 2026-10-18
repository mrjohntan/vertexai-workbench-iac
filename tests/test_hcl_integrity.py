import os
import unittest

class TestHCLIntegrity(unittest.TestCase):
    def setUp(self):
        self.root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def test_all_tf_files_balanced(self):
        tf_files = []
        for root, _, files in os.walk(self.root_dir):
            if ".git" in root:
                continue
            for f in files:
                if f.endswith(".tf"):
                    tf_files.append(os.path.join(root, f))

        self.assertGreater(len(tf_files), 10, "Should have found all Terraform files")

        for tf_path in tf_files:
            rel_path = os.path.relpath(tf_path, self.root_dir)
            with open(tf_path, "r") as f:
                content = f.read()

            # Verify balance of curly braces, brackets, and quotes outside comments
            brace_count = 0
            bracket_count = 0
            paren_count = 0
            in_string = False
            escape = False
            lines = content.splitlines()

            for line_no, line in enumerate(lines, start=1):
                stripped = line.strip()
                if stripped.startswith("#") or stripped.startswith("//"):
                    continue

                for char in line:
                    if char == '\\' and not escape:
                        escape = True
                        continue
                    if char == '"' and not escape:
                        in_string = not in_string
                    escape = False

                    if not in_string:
                        if char == '{':
                            brace_count += 1
                        elif char == '}':
                            brace_count -= 1
                        elif char == '[':
                            bracket_count += 1
                        elif char == ']':
                            bracket_count -= 1
                        elif char == '(':
                            paren_count += 1
                        elif char == ')':
                            paren_count -= 1

            self.assertEqual(brace_count, 0, f"Unbalanced braces in {rel_path}")
            self.assertEqual(bracket_count, 0, f"Unbalanced brackets in {rel_path}")
            self.assertEqual(paren_count, 0, f"Unbalanced parentheses in {rel_path}")

if __name__ == "__main__":
    unittest.main()
