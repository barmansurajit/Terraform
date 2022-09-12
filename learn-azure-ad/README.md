After adding new users to the csv; create the users first
```
terraform apply -target azuread_user.users --auto-approve
```
then apply the group assignments
```
terraform apply --auto-approve
```