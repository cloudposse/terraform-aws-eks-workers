package test

import (
	"math/rand"
	"regexp"
	"strconv"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type TerraformMapString map[string]string

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UnixNano())

	randId := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randId}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	expectedPrefix := "eg-test-suite-" + randId

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

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
	assert.Regexp(t, regexp.MustCompile(`^` + expectedPrefix + `-\d+$`) , autoscalingGroupName, "Autoscaling Group name should be our expected prefix plus a random suffix")

	// Run `terraform output` to get the value of an output variable
	var tags []TerraformMapString

	terraform.OutputStruct(t, terraformOptions, "autoscaling_group_tags", &tags)
	expectedTag := TerraformMapString{
			"key":                 "Name",
			"value":               expectedPrefix,
			"propagate_at_launch": "true",
	}

	assert.Contains(t, tags, expectedTag, `Tag "Name" should match eks-workers module ID`)

	// "kubernetes.io/cluster/${var.cluster_name}" = "owned"
	expectedTag = TerraformMapString{
		"key":                 "kubernetes.io/cluster/eg-test-eks-workers-cluster",
		"value":               "owned",
		"propagate_at_launch": "true",
	}

	assert.Contains(t, tags, expectedTag, `Tag "kubernetes.io/cluster/eg-test-eks-workers-cluster" = "owned" should be present and propagate`)

	// Run `terraform output` to get the value of an output variable
	launchTemplateArn := terraform.Output(t, terraformOptions, "launch_template_arn")
	launchTemplateId := terraform.Output(t, terraformOptions, "launch_template_id")
	// Verify we're getting back the outputs we expect
	// arn:aws:ec2:us-east-2:126450723953:launch-template/
	assert.Equal(t, "arn:aws:ec2:us-east-2:126450723953:launch-template/" + launchTemplateId, launchTemplateArn)

	// Run `terraform output` to get the value of an output variable
	securityGroupName := terraform.Output(t, terraformOptions, "security_group_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedPrefix + "-workers", securityGroupName)

	// Run `terraform output` to get the value of an output variable
	workerRoleName := terraform.Output(t, terraformOptions, "workers_role_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedPrefix + "-workers", workerRoleName)
}
