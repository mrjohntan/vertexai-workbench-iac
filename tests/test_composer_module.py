import os
import unittest

class TestComposerModule(unittest.TestCase):
    def setUp(self):
        self.mod_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "modules", "composer")

    def test_composer_files_exist(self):
        for fname in ["main.tf", "variables.tf", "outputs.tf"]:
            path = os.path.join(self.mod_dir, fname)
            self.assertTrue(os.path.exists(path), f"{fname} must exist in modules/composer")

    def test_composer_resources(self):
        path = os.path.join(self.mod_dir, "main.tf")
        if not os.path.exists(path):
            self.fail("modules/composer/main.tf does not exist")
        with open(path) as f:
            content = f.read()

        self.assertIn("google_composer_environment", content)
        self.assertIn("image_version", content)
        self.assertIn("roles/storage.objectUser", content)

        # Check default image version in variables.tf
        var_path = os.path.join(self.mod_dir, "variables.tf")
        with open(var_path) as vf:
            var_content = vf.read()
        self.assertIn("composer-3-", var_content)

    def test_composer_outputs(self):
        path = os.path.join(self.mod_dir, "outputs.tf")
        if not os.path.exists(path):
            self.fail("modules/composer/outputs.tf does not exist")
        with open(path) as f:
            content = f.read()

        for out in ["composer_env_name", "airflow_uri", "gcs_bucket_name"]:
            self.assertIn(f'output "{out}"', content)

if __name__ == "__main__":
    unittest.main()
