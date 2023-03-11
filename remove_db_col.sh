#!/bin/bash
########################


## Restore data files 
 cat /dev/null > db_commands.js
 cat /dev/null > dbs_names


## Choose namespace you need to create db on 
echo -e " 
Please, Choose what you need to remove? (Press q to exit)
1) $red Remove $NC Database 
2) $red Remove $NC Collection"
while :
    do
    read choose
    case $choose in
            1)
               type="databse"
               break
               ;;
            2)
	             type="collection"
               break
               ;;
            q)
               exit 1
               ;;
            *)
               echo -e "please choose correct action .\n"
               ;;
    esac
done
########################
#apply namespace fn 
namespace_fn
########################
## Remoce DB || collections 
if [[ $type == "databse" ]] ;then 
#remove Database
add_db=y 
    while  [ "$add_db" == "y" ] ||  [ "$add_db" == "yes" ]
    do	


      echo -e "$Cyan Please, enter the Database Name. $NC"
      read db_name;

        # Add DBs Names to dbs_names & db_commands.js
      echo "$db_name" >> dbs_names
      echo "use $db_name" >> db_commands.js
      echo "db.runCommand({ \"dropDatabase\": 1 })" >> db_commands.js
        # check if need to remove another dbs
      echo -e "$UCyan*** Do you need to remove another Database y or n *** $NC \n"
      read add_db
    done
    outputs=$(cat dbs_names)
      echo -e "
You are going to delete the following: ,      

+------------+------------+              
   DataBases                       
+------------+------------+             
$red$(printf %-14s "$outputs")        $NC            
+------------+------------+   

$green Please, Write yes to continue $NC
      "
      read db_continue 
      
      if [[ $db_continue != "yes"  ]] ;then
          exit
      fi
elif [[ $type == "collection" ]] ;then 
 #remove collections


      echo -e "$Cyan Please, enter the Database Name  .. $NC"
      read db_name;
      echo "$db_name" >> dbs_names
      echo "use $db_name" >> db_commands.js

add_col=y

      while [ "$add_col" == "y" ] || [ "$add_col" == "yes" ]
      do	
            

            echo -e "$Cyan Please, enter the collection name of $db_name DB $NC \n"
            read col_names;

            # Add collections Names to db_commands.js
            
            echo "db.runCommand({ \"drop\" : \"$col_names\"})" >> db_commands.js
            echo -e  "$UCyan *** Do you need to remove another collection y or n *** $NC \n"
            echo "$col_names" >> cols_names
            
            read add_col
      done 

      outputs=$(cat cols_names )
      echo -e "
$red You are going to delete the following: $NC,      

+---------------+-----------------------+              
   Collections of $db_name Database.                      
+---------------+-----------------------+              
$red$(printf %-14s "$outputs")        $NC            
+---------------+-----------------------+  

$green Please, Write yes to continue $NC

      "
      read db_continue 
      
      if [[ $db_continue != "yes"  ]]  ;then
          exit 
      fi

else

echo -e " $red The type you need to delete is incorrect $NC "

fi
############
#apply secret variables function.
secret_var 

################################################################################################
# Starting Deployment Process 
cm_check
########################
# run mongosh pod and db-creation configmap 
kubectl delete pod mongosh -n dxl-pre-cz &>/dev/null
helm upgrade mongo-db-creation  mongo-chart/. -n dxl-pre-cz &>/dev/null
sleep 4

########################
#Remove ConfigMap   
sleep 12
kubectl delete cm db-creation -n dxl-pre-cz &>/dev/null
kubectl delete pod mongosh -n dxl-pre-cz  &>/dev/null
####################
# delete collection file 
rm -rf cols_names


