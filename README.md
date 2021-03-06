
## Boards

### Setup

* install the ruby app `spanner`

```
git clone git@github.com:themi/spanner.git
cd spanner

# configure ruby manager for 2.5.1@spanner

gem install bundler
bundle
```

### Review config

```
TRELLO_MEMBER_NAME
TRELLO_DEVELOPER_PUBLIC_KEY
TRELLO_MEMBER_TOKEN
TRELLO_OATH_SECRET  (currently not required)
```


### How to use

* Display onboarding statistics

```
./bin/baords stats
```

displays all client apps onboarded or otherwise then summerizes there current status



## AWS Organisations

### Onetime Setup

* Create User (programmatic access access only) `organisations-admin-user`, attach the AWS Managed Policy `AdministratorAccess` and take note of the aws_access_key_id and aws_secret_access_key.

* Goto IAM Policies and create policy `organisations-account-admin-policy`.

```
# organisations-account-admin-policy
# Allow create accounts and login to it to add the OpsCare onbording user
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "OrganisationsAccountMaintenance",
            "Effect": "Allow",
            "Action": [
                "organizations:ListAccounts",
                "organizations:CreateAccount",
                "organizations:DescribeCreateAccountStatus"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AssumeRoleAccountMaintenance",
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "arn:aws:iam::*:role/OrganizationAccountAccessRole"
        }
    ]
}
```

* Create User (programmatic access access only) `organisations-account-admin-user`, attach the above policy and record the aws_access_key_id and aws_secret_access_key.

* Create file `~/.aws/credentials` and add the following:

```
[organisation-admin]
aws_access_key_id=blah
aws_secret_access_key=blah

[account-admin]
aws_access_key_id=blah
aws_secret_access_key=blah
```

* install the ruby app `spanner`

```
git clone git@github.com:themi/spanner.git
cd spanner

# configure ruby manager for 2.5.1@spanner

gem install bundler
bundle
```

* review/update the settings in file `./initializers/aws_organisations.rb`

```
AwsOrganisations.configure do |c|
  c.admin_profile         = "organisation-admin"
  c.account_admin_profile = "account-admin"
  c.account_access_role   = "OrganizationAccountAccessRole"
  c.email_template        = "support+%{ACCOUNT_NAME}@reinteractive.net"
  c.account_name_template = "OpsCare %{ACCOUNT_NAME}"
  c.sts_external_id       = "reinteractive-OpsCare"
  c.onboarding_ic         = "tim@reinteractive.net"
end
```


### How to use

This utility: `./bin/aws_organisations`  uses `thor` so just run it by itself to get some help.


#### To create a new AWS Account as a member

* create the account

```
aws_organisations create "First National Bank"
```

Take note of the resulting ACCOUNT_ID then...


* initialise the account with opscare user


```
aws_organisations setup_user ACCOUNT_ID
```

topsekr.it the output to Onboarding I/C


* Finally reset the root password of the new account (optional).

