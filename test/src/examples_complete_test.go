package test

import (
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"os"
	"regexp"
	"strings"
	"testing"
)

type ASGTagStruct struct {
	Key               string `json:"key"`
	Value             string `json:"value"`
	PropagateAtLaunch bool   `json:"propagate_at_launch"`
}

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	os.RemoveAll(tempTestFolder)
}

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}
	// Keep the output quiet
	if !testing.Verbose() {
		terraformOptions.Logger = logger.Discard
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	expectedPrefix := "eg-test-suite-" + randID

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "172.16.0.0/16", vpcCidr)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.0.0/19", "172.16.32.0/19"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.96.0/19", "172.16.128.0/19"}, publicSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	// autoscaling_group_name = eg-test-suite-20210416185727403200000006
	autoscalingGroupName := terraform.Output(t, terraformOptions, "autoscaling_group_name")
	// Verify we're getting back the outputs we expect
	assert.Regexp(t, regexp.MustCompile(`^`+expectedPrefix+`-`), autoscalingGroupName, "Autoscaling Group name should be our expected prefix plus a random suffix")

	// Run `terraform output` to get the value of an output variable
	var tags []ASGTagStruct

	terraform.OutputStruct(t, terraformOptions, "autoscaling_group_tags", &tags)
	expectedTag := ASGTagStruct{
		Key:               "Name",
		Value:             expectedPrefix,
		PropagateAtLaunch: true,
	}

	assert.Contains(t, tags, expectedTag, `Tag "Name" should match eks-workers module ID`)

	// "kubernetes.io/cluster/${var.cluster_name}" = "owned"
	expectedTag = ASGTagStruct{
		Key:               "kubernetes.io/cluster/eg-test-eks-workers-cluster",
		Value:             "owned",
		PropagateAtLaunch: true,
	}

	assert.Contains(t, tags, expectedTag, `Tag "kubernetes.io/cluster/eg-test-eks-workers-cluster" = "owned" should be present and propagate`)

	// Run `terraform output` to get the value of an output variable
	launchTemplateArn := terraform.Output(t, terraformOptions, "launch_template_arn")
	launchTemplateId := terraform.Output(t, terraformOptions, "launch_template_id")
	// Verify we're getting back the outputs we expect
	// arn:aws:ec2:us-east-2:126450723953:launch-template/
	assert.Equal(t, "arn:aws:ec2:us-east-2:126450723953:launch-template/"+launchTemplateId, launchTemplateArn)

	// Run `terraform output` to get the value of an output variable
	securityGroupName := terraform.Output(t, terraformOptions, "security_group_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedPrefix+"-workers", securityGroupName)

	// Run `terraform output` to get the value of an output variable
	workerRoleName := terraform.Output(t, terraformOptions, "workers_role_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedPrefix+"-workers", workerRoleName)
}

/*
func TestExamplesCompleteDisabled(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
			"enabled":    "false",
		},
	}
	// Keep the output quiet
	if !testing.Verbose() {
		terraformOptions.Logger = logger.Discard
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Get all the output and lookup a field. Pass if the field is missing or empty.
	datadogMonitorNames := terraform.OutputAll(t, terraformOptions)["datadog_monitor_names"]

	// Verify we're getting back the outputs we expect
	assert.Empty(t, datadogMonitorNames, "When disabled, module should have no outputs.")
}

*/
