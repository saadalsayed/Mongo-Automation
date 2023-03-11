clear
#### Colors variables
Purple='\033[0;35m';
red='\033[0;31m';
green='\033[0;32m';
NC='\033[0m';
Cyan='\033[0;36m' ;
UCyan='\033[4;36m';
Yellow='\033[0;33m';

echo -e " $Purple
    
 _______                            _______                                    _                 ______             _            
(_______)                          (_______)        _                      _  (_)               / _____)           (_)       _   
 _  _  _  ___  ____   ____  ___     _______ _   _ _| |_ ___  ____  _____ _| |_ _  ___  ____    ( (____   ____  ____ _ ____ _| |_ 
| ||_|| |/ _ \|  _ \ / _  |/ _ \   |  ___  | | | (_   _) _ \|    \(____ (_   _) |/ _ \|  _ \    \____ \ / ___)/ ___) |  _ (_   _)
| |   | | |_| | | | ( (_| | |_| |  | |   | | |_| | | || |_| | | | / ___ | | |_| | |_| | | | |   _____) | (___| |   | | |_| || |_ 
|_|   |_|\___/|_| |_|\___ |\___/   |_|   |_|____/   \__)___/|_|_|_\_____|  \__)_|\___/|_| |_|  (______/ \____)_|   |_|  __/  \__)
                    (_____|                                                                                          |_|         
                                                                                                                                                                                                                                
                                                                                                                    
$NC"


echo -e "Please, choose which action is needed (press q to Quit)
1) create Database or collections
2) remove Database or collections
3) migrate database from local mongo to atlas 
"
while :
    do
    read number
    case $number in
            1)
               fn_name="create_fn"
               break
               ;;
            2)
	            fn_name="delete_fn"
               break
               ;;
            3)
               fn_name="migrate_fn"
               break
                ;;

            q)
               exit 1
               ;;
            *)
               echo -e "please choose correct action.\n"
               ;;
    esac
done


### namespace Function
namespace_fn() {
## Choose namespace you need to create db on 
echo -e " $Cyan
Please, Enter cluster Name (press q to Quit)
1) dxl-pre-cz
2) dxl-sys-cz
3) dxl-dev-cz
4) dxl-int-cz

 $NC"
while :
    do
    read number
    case $number in
            1)
               namespace="dxl-pre-cz"
               break
               ;;
            2)
	             namespace="dxl-sys-cz"
               break
               ;;
            3)
               namespace="dxl-dev-cz"
               break
                ;;
            4)
               namespace="dxl-int-cz"
               break
               ;;
            5)
               namespace="dxl-prod-cz"
               break
               ;;
            q)
               exit 1
               ;;
            *)
               echo -e "please choose correct namespace.\n"
               ;;
    esac
done

}
########
secret_var() {
#Depending on the namespace you select choose the secret variable in mongosh pod and its values
Cureent_secret=$(grep -oE ".namespace_[a-z A-Z].*.secret.name" mongo-chart/templates/mongosh.yaml);  
 
if [[ $namespace == "dxl-pre-cz" ]] ;then 
     sed -i '' -e "s/$Cureent_secret/.namespace_pre.secret.name/" mongo-chart/templates/mongosh.yaml
   elif [[ $namespace == "dxl-dev-cz" ]] ; then
     sed -i '' -e "s/$Cureent_secret/.namespace_dev.secret.name/" mongo-chart/templates/mongosh.yaml
   elif [[ $namespace == "dxl-int-cz" ]] ; then
     sed -i '' -e "s/$Cureent_secret/.namespace_int.secret.name/" mongo-chart/templates/mongosh.yaml
   elif [[ $namespace == "dxl-sys-cz" ]] ; then
     sed -i '' -e "s/$Cureent_secret/.namespace_sys.secret.name/" mongo-chart/templates/mongosh.yaml
   elif [[ $namespace == "dxl-prod-cz" ]] ; then
     sed -i '' -e "s/$Cureent_secret/.namespace_prod.secret.name /" mongo-chart/templates/mongosh.yaml
   else 
     echo "Secret not selected successfully " 
fi
}
########
output_show() {
outputs=$(cat dbs_names)
cat << EOT  

The Following DBs will be created : 

+---------------+-------------------+              
|          DataBase                 |              
+---------------+-------------------+              
$(printf %-14s "$outputs")                   
+---------------+-------------------+              

EOT
    
}
########
cm_check() {
check_cm=$(kubectl get cm db-creation -n dxl-pre-cz   2>/dev/null  | grep -v NAME | awk '{print $1}') 

if [[ $check_cm == "db-creation"  ]] ; then

  echo -e  "$Cyan 
db-creation ConfigMap is already created , Going to Recreate it
 $NC"

  kubectl delete cm db-creation -n dxl-pre-cz  &>/dev/null
  kubectl create cm db-creation --from-file=db_commands.js  -n dxl-pre-cz  &>/dev/null
else 

    kubectl create cm db-creation --from-file=db_commands.js  -n dxl-pre-cz  &>/dev/null
    sleep  3
fi


}
########
########
recreate_fn() {
    sleep 11
    kubectl delete pod mongosh -n dxl-pre-cz
    cm_check 
    helm upgrade mongo-db-creation  mongo-chart/. -n dxl-pre-cz &>/dev/null
}
########
jira_fn() {

   #Edit Cluster-Name in jira ticket
   cluster_type=$( echo $namespace | awk '{print substr($0,5,3)}') 
  DB_new_users=$(sed -e "s/$/_dba_$cluster_type/" dbs_names |awk '{print $0, " "}'  | tr -d "\n")
  DB_new=$(awk '{print $0," "}'  dbs_names | tr -d "\n")
  sed -i '' -e '/data needed:/a\'$'\n'"User-Name= $DB_new_users -" jira-ticket/vars/jira-vars.yaml  &>/dev/null;
  sed -i '' -e '/data needed:/a\'$'\n'"Databse-Name= $DB_new -" jira-ticket/vars/jira-vars.yaml  &>/dev/null;
  sed -i '' -e '/data needed:/a\'$'\n'"namepsace= $namespace -" jira-ticket/vars/jira-vars.yaml  &>/dev/null;

}
#######
#helm_check_fb() {

 #  helm_name=$(helm list -n dxl-pre-cz  2>/dev/null | grep mongo-db-creation | awk '{print $1}')
#}
#######################################################
## Start script 
if [[ $fn_name == "create_fn"  ]]; then 
. db_col_creation.sh

elif [[ $fn_name == "delete_fn"  ]]; then 
. remove_db_col.sh

elif [[ $fn_name == "migrate_fn"  ]]; then 
namespace_fn 
echo "fn_name is migrate_fn"


else
  echo -e "Action is not correct"
fi