#!/bin/bash
########################

#apply namespace fn 
namespace_fn

## Restore data files 
 cat /dev/null > db_commands.js
 cat /dev/null > dbs_names
sed -i '' -e  '/^namepsace/d' jira-ticket/vars/jira-vars.yaml
sed -i '' -e  '/^Databse-Name/d' jira-ticket/vars/jira-vars.yaml
sed -i '' -e  '/^User-Name/d' jira-ticket/vars/jira-vars.yaml
########################
## Choose DB you need to create 
add_db=y 
while  [ "$add_db" == "y" ]
do	


  echo -e "$Cyan
Please, enter DB Name
 $NC"
  read db_name;

    # Add DBs Names to dbs_names & db_commands.js
  echo "$db_name" >> dbs_names
  echo "use $db_name" >> db_commands.js

  ########################
  ## Write the collections you need to create 
  ## Create a loop if you need to create more collection 

  add_col=y
    while [ "$add_col" == "y" ]
    do	
          echo -e "$Cyan
Please, enter collections of $db_name database
 $NC"
          read col_names;

          # Add collections Names to db_commands.js
          echo "db.createCollection(\"$col_names\")" >> db_commands.js

          echo -e  "\n $UCyan *** Do you need to add another collection y or n *** $NC \n"
          read add_col
    done 
    echo -e "\n $UCyan*** Do you need to add another Database y or n *** $NC \n"
    read add_db
done
echo "show dbs" >>  db_commands.js
########################
#apply secret variables function.
secret_var 

################################################################################################
#### Check Before Deploy 
output_show 
sleep 1
################################################################################################
## Starting Deployment Process 
cm_check
########################
# run mongosh pod and db-creation configmap 

   # Cureent_spoc=$(grep -oE ".Values.clustertype.*prod" mongo-chart/templates/mongosh.yaml);  
    
  #  if [[ $namespace == "dxl-prod-cz" ]] ;then 
  #      kubectl config use-context saad.abdelhamid-dxl-prd
  #      sed -i '' -e "s/$Cureent_spoc/.Values.clustertypeprod/" mongo-chart/templates/mongosh.yaml
  #      helm upgrade mongo-db-creation  mongo-chart/. -n dxl-prod-cz &>/dev/null

   #   else 
   #     kubectl config use-context saad.abdelhamid-dxl-nonprod
   #     sed -i '' -e "s/$Cureent_spoc/.Values.clustertypenonprod/" mongo-chart/templates/mongosh.yaml
   #     helm install mongo-db-creation  mongo-chart/. -n dxl-pre-cz &>/dev/null
        # helm upgrade mongo-db-creation  mongo-chart/. -n dxl-prod-cz &>/dev/null
   # fi
#####
helm upgrade mongo-db-creation  mongo-chart/. -n dxl-pre-cz &>/dev/null

#Remove ConfigMap 
#kubectl delete cm db-creation -n dxl-pre-cz &>/dev/null

## edit the jira file
jira_fn
### recreate function
echo -e  " $Yellow Recreate the same database and collections for another namespace clsuter (y or n ) $NC"
read answer

if [[  $answer == y ]] || [[  $answer == yes ]] ;then
    add_cluster=y 
    while  [ "$add_cluster" == "y" ]
    do

    echo "which cluster namespace"
    namespace_fn
   
  
    Cureent_secret=$(grep -oE ".namespace_[a-z A-Z].*.secret.name" mongo-chart/templates/mongosh.yaml); 
  if [[ $namespace == "dxl-pre-cz" ]] ;then 
     
     sed -i '' -e "s/$Cureent_secret/.namespace_pre.secret.name/" mongo-chart/templates/mongosh.yaml
     recreate_fn  &>/dev/null
     jira_fn
   elif [[ $namespace == "dxl-dev-cz" ]] ; then
     sed -i '' -e "s/$Cureent_secret/.namespace_dev.secret.name/" mongo-chart/templates/mongosh.yaml
     recreate_fn   &>/dev/null
     jira_fn
   elif [[ $namespace == "dxl-int-cz" ]] ; then
   
     sed -i '' -e "s/$Cureent_secret/.namespace_int.secret.name/" mongo-chart/templates/mongosh.yaml
    recreate_fn &>/dev/null
    jira_fn
   elif [[ $namespace == "dxl-sys-cz" ]] ; then

     sed -i '' -e "s/$Cureent_secret/.namespace_sys.secret.name/" mongo-chart/templates/mongosh.yaml
    recreate_fn &>/dev/null
    jira_fn
   elif [[ $namespace == "dxl-prod-cz" ]] ; then
     sed -i '' -e "s/$Cureent_secret/.namespace_prod.secret.name /" mongo-chart/templates/mongosh.yaml
    recreate_fn &>/dev/null
    jira_fn
   else 
     echo "Secret not selected successfully " 
  fi
  echo -e "$Yellow add in another cluster ( y or n )?  $NC"
  read add_cluster

  done
fi


sleep 12
kubectl delete cm db-creation -n dxl-pre-cz &>/dev/null
kubectl delete pod mongosh -n dxl-pre-cz  &>/dev/null

####################
### Create Jira Ticket 
echo -e " $green Do you need to create A Ticket for DB Users? (y/n) $NC"
read create_ticket

if [[  $create_ticket == y ]] || [[  $create_ticket == yes ]] ; then
   
  #run playbook
 ANSIBLE_STDOUT_CALLBACK=minimal ansible-playbook -i jira-ticket/inventory jira-ticket/gat-ticket.yaml 
  
  #echo " Ansible Playbook is installed "
  else 
  echo -e " Ticket is $red skipped $NC, Will be done manually "
fi