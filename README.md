on your laptop, apply terraform directory in order to make ec2 and others. 
Then WITH YOUR laptop again, execute ansible and test configs like this.(you can make an extra machine, or use your own laptop.) 

BEFORE RUN ANSIBLE, DO THESE

1- Test inventory 
ansible-inventory -i inventory_aws.yml --graph
result: jenkins-sq-deploy

2- check SSH 
ansible -i inventory_aws.yml all -m ping
if you get "pong", it'll be okay, otherwise check (key, sg, wrong user)

3- This must be work. 
ssh -i your-key.pem ubuntu@EC2_IP

4- Finally run this for ansible
ansible-playbook -i inventory.yml site.yml



After ansible: 
-- Check jenkins machine and its ip:8080 and password

-- SQ: sonar:9000

-- Deploy server: docker ps
Done Infrastructure. 

if a role is fail, DO NOT start playbook from zero, with this command you can start from any stage. ==> "--limit [name]"




------------
other: 

Pay attention to sg, and ec2 file must import sg in order to use it. 
pay attention to public key 
consider inventory and hostnames and tags in terraform and ansible. 

Create your own ssh key and put in on terraform, ansible for connection. 


After all of these, write deploy logic yaml file. 
So first of all, make a logic for the project, Then do it on jenkins and orchestrate it. 

Preparing servers for deployment is called bootstrap. 


=================================
Create a yaml file for deployment, because we need to use it with ansible with pipeline. 

Each time in jenkins for ansible: 
Pull image - Migration - Run container - health check. ==> It's deployment task and everytime should be checked. 
it must be used INSIDE the pipeline, bootstrap must be outside. 


Template: 
a file which is filled with variables in Ansible, and it becomes to a real file or variable
it means that we define something, and when we deploy it on server, it'll become a true variable. it's dynamic. 

4 methods for defining variables. 

1- in commandline 
ansible-playbook deploy.yml --extra-vars "app_port=3000 database_url=..." 
Good for testing, bad for pipeline and prod. 

2- inside the playbook: 
vars: 
  app_port: 3000
  database_url: .... 
Simple -- Not good (secret leak)

3- variable files
create a var folder and make a yaml file with the variables, and use this 
ansible-playbook deploy_app.yml -e "@vars/dev.yml"

Pay attentio: DO NOT push it to git if you have credentials. 

4- in jenkins pipeline. 