import os
import unittest

class TestDocumentation(unittest.TestCase):
    def setUp(self):
        self.root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def test_readme_exists_and_complete(self):
        readme_path = os.path.join(self.root_dir, "README.md")
        self.assertTrue(os.path.exists(readme_path), "README.md must exist in root")
        with open(readme_path) as f:
            content = f.read()
        self.assertIn("Vertex AI Workbench", content)
        self.assertIn("asia-southeast1", content)
        self.assertIn("terraform apply", content)
        self.assertIn("terraform destroy", content)

    def test_runbook_exists_and_complete(self):
        runbook_path = os.path.join(self.root_dir, "docs", "RUNBOOK.md")
        self.assertTrue(os.path.exists(runbook_path), "docs/RUNBOOK.md must exist")
        with open(runbook_path) as f:
            content = f.read()
        self.assertIn("Runbook", content)
        self.assertIn("Dataproc", content)
        self.assertIn("Composer", content)
        self.assertIn("Troubleshooting", content)

if __name__ == "__main__":
    unittest.main()
