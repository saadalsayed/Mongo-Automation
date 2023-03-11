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
# enter local mongo url
echo "Please, source mongo URL "
read mongo_url


########################
## Remoce DB || collections 
if [[ $type == "databse" ]] ;then 
#remove Database
add_db=y 
    while  [ "$add_db" == "y" ] ||  [ "$add_db" == "yes" ]
    do	

      echo -e "$Cyan Please, enter the Source Database Name. $NC"
      read src_db_name;

      echo -e "$Cyan Please, enter the source Database user. $NC"
      read src_db_user;

      echo -e "$Cyan Please, enter the source  Database password. $NC"
      read src_db_pass;

      echo -e "$Cyan Please, enter the destination Database Name. $NC"
      read dst_db_name;

      echo -e "$Cyan Please, enter the destination Database user. $NC"
      read dst_db_user;

      echo -e "$Cyan Please, enter the destination Database password. $NC"
      read dst_db_pass;

        # Add DBs Names to dbs_names & db_commands.js

      echo "mongodump --uri=mongodb://$src_db_name:$src_db_pass@$mongo_url:27017/$src_db_name  --out=/tmp/$src_db_name.bson ">> db_commands.js
      echo "mongorestore --uri $URL --username $dst_db_user -p $dst_db_pass --db=$dst_db_name  /tmp/$src_db_name.bson" >> db_commands.js

        # check if need to remove another dbs
      echo -e "$UCyan*** Do you need to remove another Database y or n *** $NC \n"
      read add_db

    done
    
elif [[ $type == "collection" ]] ;then 
 #migrate collections


    echo -e "$Cyan Please, enter the Source Database Name. $NC"
      read src_db_name;

      echo -e "$Cyan Please, enter the source Database user. $NC"
      read src_db_user;

      echo -e "$Cyan Please, enter the source  Database password. $NC"
      read src_db_pass;

      echo -e "$Cyan Please, enter the destination Database Name. $NC"
      read dst_db_name;

      echo -e "$Cyan Please, enter the destination Database user. $NC"
      read dst_db_user;

      echo -e "$Cyan Please, enter the destination Database password. $NC"
      read dst_db_pass;
 
     

add_col=y

      while [ "$add_col" == "y" ] || [ "$add_col" == "yes" ]
      do	
            
            echo -e "$Cyan Please, enter the collection Name. $NC"
            read coll_name;


         echo "mongodump --uri=mongodb://$src_db_name:$src_db_pass@$mongo_url:27017/$src_db_name  --out=/tmp/$src_db_name.bson ">> db_commands.js
          echo "mongorestore --uri $URL --username $dst_db_user -p $dst_db_pass --collection=$coll_name --db=$dst_db_name  /tmp/$src_db_name.bson" >> db_commands.js

            echo -e  "$UCyan *** Do you need to add another collection y or n *** $NC \n"
            read add_col

      done 

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

helm upgrade mongo-db-creation  mongo-chart/. -n dxl-pre-cz &>/dev/null
sleep 4

########################
#Remove ConfigMap   
kubectl delete cm db-creation -n dxl-pre-cz &>/dev/null
####################


