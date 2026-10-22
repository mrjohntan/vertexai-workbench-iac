import os
import unittest

class TestIAMModule(unittest.TestCase):
    def setUp(self):
        self.mod_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "modules", "iam")

    def test_iam_files_exist(self):
        for fname in ["main.tf", "variables.tf", "outputs.tf"]:
            path = os.path.join(self.mod_dir, fname)
            self.assertTrue(os.path.exists(path), f"{fname} must exist in modules/iam")

    def test_iam_resources(self):
        path = os.path.join(self.mod_dir, "main.tf")
        if not os.path.exists(path):
            self.fail("modules/iam/main.tf does not exist")
        with open(path) as f:
            content = f.read()

        # Service Accounts
        self.assertIn("sa-workbench", content)
        self.assertIn("sa-dataproc", content)
        self.assertIn("sa-composer", content)

        # Service Account IAM Roles
        self.assertIn("roles/notebooks.runner", content)
        self.assertIn("roles/dataproc.editor", content)
        self.assertIn("roles/composer.user", content)
        self.assertIn("roles/dataproc.worker", content)
        self.assertIn("roles/composer.worker", content)

        # Impersonation & SA User
        self.assertIn("roles/iam.serviceAccountUser", content)
        self.assertIn("roles/iam.serviceAccountTokenCreator", content)
        self.assertIn("workbench_actas_dataproc", content)
        self.assertIn("composer_actas_dataproc", content)
        self.assertIn("composer_roles", content)

    def test_iam_outputs(self):
        path = os.path.join(self.mod_dir, "outputs.tf")
        if not os.path.exists(path):
            self.fail("modules/iam/outputs.tf does not exist")
        with open(path) as f:
            content = f.read()

        for out in ["workbench_sa_email", "workbench_sa_id", "dataproc_sa_email", "composer_sa_email"]:
            self.assertIn(f'output "{out}"', content)

if __name__ == "__main__":
    unittest.main()
