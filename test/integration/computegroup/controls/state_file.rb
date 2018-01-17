# More info please refer to: https://www.inspec.io/docs/

# Get path to terraform state file from attribute of kitchen-terraform.
terraform_state = attribute "terraform_state", {}

#Define how critical this control is.
control "state_file" do
  # Define how critical this control is.
  impact 0.6
  # The actual test case.
  describe "the Terraform state file" do
    # Get json object of terraform state file.
    subject do json(terraform_state).modules[1]["resources"]["azurerm_virtual_machine_scale_set.vm-linux"]["type"] end
   
    # Validate the terraform resource type vmscaleset is present.
    it "is valid" do is_expected.to match /azurerm_virtual_machine_scale_set/ end
  end
end
