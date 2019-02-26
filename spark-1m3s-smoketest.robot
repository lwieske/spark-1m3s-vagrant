*** Settings ***

Documentation           Smoketesting Spark Cluster ( 1 Master / 3 Slaves )
Library                 Collections
Library                 OperatingSystem
Library                 String
Suite Setup             Startup spark
# Suite Teardown          Shutdown spark

*** Variables ***

*** Test Cases ***

Virtual machines are running
    ${result} =         Run              vagrant status master | grep master
                        Should contain   ${result}   running
    ${result} =         Run              vagrant status slave-01 | grep slave-01
                        Should contain   ${result}   running
    ${result} =         Run              vagrant status slave-02 | grep slave-02
                        Should contain   ${result}   running
    ${result} =         Run              vagrant status slave-03 | grep slave-03
                        Should contain   ${result}   running

Daemons on master are running
    ${result} =         Execute on      master      jps
                        Should contain  ${result}   ${SPACE}HistoryServer
                        Should contain  ${result}   JobHistoryServer
                        Should contain  ${result}   Master
                        Should contain  ${result}   ResourceManager
                        Should contain  ${result}   NameNode

Daemons on slave-01 are running
    ${result} =         Execute on      slave-01    jps
                        Should contain  ${result}   Worker
                        Should contain  ${result}   NodeManager
                        Should contain  ${result}   DataNode

Daemons on slave-02 are running
    ${result} =         Execute on      slave-02    jps
                        Should contain  ${result}   Worker
                        Should contain  ${result}   NodeManager
                        Should contain  ${result}   DataNode

Daemons on slave-03 are running
    ${result} =         Execute on      slave-03    jps
                        Should contain  ${result}   Worker
                        Should contain  ${result}   NodeManager
                        Should contain  ${result}   DataNode

HDFS NameNode started
    ${result} =         Execute on      master      jps
                        Should contain  ${result}   NameNode

HDFS DataNode 01 started
    ${result} =         Execute on      slave-01    jps
                        Should contain  ${result}   DataNode

HDFS DataNode 02 started
    ${result} =         Execute on      slave-02    jps
                        Should contain  ${result}   DataNode

HDFS DataNode 03 started
    ${result} =         Execute on      slave-03    jps
                        Should contain  ${result}   DataNode

HDFS NameNode registered DataNode 01
                        Run             vagrant scp master:/var/log/hadoop-vagrant-namenode-master.log ./varlog
    ${logrecs} =        Grep File       ./varlog/hadoop-vagrant-namenode-master.log     NetworkTopology
                        Should contain  ${logrecs}                                      NetworkTopology: Adding a new node: /default-rack/10.10.10.201:9866

HDFS NameNode registered DataNode 02
    ${logrecs} =        Grep File       ./varlog/hadoop-vagrant-namenode-master.log     NetworkTopology
                        Should contain  ${logrecs}                                      NetworkTopology: Adding a new node: /default-rack/10.10.10.202:9866

HDFS NameNode registered DataNode 03
    ${logrecs} =        Grep File       ./varlog/hadoop-vagrant-namenode-master.log     NetworkTopology
                        Should contain  ${logrecs}                                      NetworkTopology: Adding a new node: /default-rack/10.10.10.203:9866

YARN ResourceManager started
    ${result} =         Execute on      master        jps
                        Should contain  ${result}     ResourceManager

YARN NodeManager 01 started
    ${result} =         Execute on      slave-01      jps
                        Should contain  ${result}     NodeManager

YARN NodeManager 02 started
    ${result} =         Execute on      slave-02      jps
                        Should contain  ${result}     NodeManager

YARN NodeManager 03 started
    ${result} =         Execute on      slave-03      jps
                        Should contain  ${result}     NodeManager

YARN ResourceManager registered NodeManager 01
                        Run             vagrant scp master:/var/log/hadoop-vagrant-resourcemanager-master.log ./varlog
    ${logrecs} =        Grep File       ./varlog/hadoop-vagrant-resourcemanager-master.log      NodeManager from node slave-01
                        Should contain  ${logrecs}                                              registered

YARN ResourceManager registered NodeManager 02
    ${logrecs} =        Grep File       ./varlog/hadoop-vagrant-resourcemanager-master.log      NodeManager from node slave-02
                        Should contain  ${logrecs}                                              registered

YARN ResourceManager registered NodeManager 03
    ${logrecs} =        Grep File       ./varlog/hadoop-vagrant-resourcemanager-master.log      NodeManager from node slave-03
                        Should contain  ${logrecs}                                              registered

SPARK Master (Standalone) started
    ${result} =         Execute on      master        jps
    Should contain      ${result}       Master
    ${result} =         Execute on      master        sudo systemctl status spark-standalone-master -l | head -3 | tail -1
    Should contain      ${result}       Active: active (running)
    ${result} =         Execute on      master        sudo systemctl status spark-standalone-master -l | tail -1
    Should contain      ${result}       master systemd[1]: Started SPARK Standalone Master Service

SPARK Worker 01 (Standalone) started
    ${result} =         Execute on      slave-01      jps
    Should contain      ${result}       Worker
    ${result} =         Execute on      slave-01      sudo systemctl status spark-standalone-slave -l | head -3 | tail -1
    Should contain      ${result}       Active: active (running)
    ${result} =         Execute on      slave-01      sudo systemctl status spark-standalone-slave -l | tail -1
    Should contain      ${result}       slave-01 systemd[1]: Started SPARK Standalone Slave Service

SPARK Worker 02 (Standalone) started
    ${result} =         Execute on      slave-02      jps
    Should contain      ${result}       Worker
    ${result} =         Execute on      slave-02      sudo systemctl status spark-standalone-slave -l | head -3 | tail -1
    Should contain      ${result}       Active: active (running)
    ${result} =         Execute on      slave-02      sudo systemctl status spark-standalone-slave -l | tail -1
    Should contain      ${result}       slave-02 systemd[1]: Started SPARK Standalone Slave Service

SPARK Worker 03 (Standalone) started
    ${result} =         Execute on      slave-03      jps
    Should contain      ${result}       Worker
    ${result} =         Execute on      slave-03      sudo systemctl status spark-standalone-slave -l | head -3 | tail -1
    Should contain      ${result}       Active: active (running)
    ${result} =         Execute on      slave-03      sudo systemctl status spark-standalone-slave -l | tail -1
    Should contain      ${result}       slave-03 systemd[1]: Started SPARK Standalone Slave Service

SPARK Master registered Worker 01
                        Run             vagrant scp master:/var/log/spark-vagrant-org.apache.spark.deploy.master.Master-1-master.out ./varlog
    ${logrecs} =        Grep File       ./varlog/spark-vagrant-org.apache.spark.deploy.master.Master-1-master.out       worker 10.10.10.201
                        Should contain  ${logrecs}                                                                      Registering

SPARK Master registered Worker 02
    ${logrecs} =        Grep File       ./varlog/spark-vagrant-org.apache.spark.deploy.master.Master-1-master.out       worker 10.10.10.202
                        Should contain  ${logrecs}                                                                      Registering

SPARK Master registered Worker 03
    ${logrecs} =        Grep File       ./varlog/spark-vagrant-org.apache.spark.deploy.master.Master-1-master.out       worker 10.10.10.203
                        Should contain  ${logrecs}                                                                      Registering

#lsof -i | grep -e LISTEN
#netstat -lnptu
#systemctl status spark-standalone-master.service -l

Calculate PI with mapreduce
    ${result} =         Execute on      master                  yarn jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.0.jar pi 10 1000
                        Should contain  ${result}               Job Finished
                        Should contain  ${result}               Estimated value of Pi is 3.14

Run wordcount with mapreduce
                        Run             vagrant scp ./data/input/alice_in_wonderland.txt master:/tmp/alice_in_wonderland.txt
                        Execute on      master                  hdfs dfs -copyFromLocal /tmp/alice_in_wonderland.txt /
    ${result} =         Execute on      master                  yarn jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.0.jar wordcount /alice_in_wonderland.txt /wordcount
                        Should contain  ${result}               completed successfully
                        Execute on      master                  hdfs dfs -copyToLocal /wordcount/part-r-00000 /tmp/wordcount
                        Run             vagrant scp master:/tmp/wordcount data/output/wordcount
    ${justs} =          Grep File       data/output/wordcount   just
                        Should Contain  ${justs}                43
                        Execute on      master                  hdfs dfs -rm /alice_in_wonderland.txt
                        Execute on      master                  hdfs dfs -rm -r /wordcount
                        Execute on      master                  rm -f /tmp/wordcount
                        Remove File     data/output/wordcount

Calculate PI with spark (locally on 2 cores)
    ${result} =         Execute on      master                  spark-submit --class org.apache.spark.examples.SparkPi --master local[2] /usr/local/spark/examples/jars/spark-examples_2.11-2.4.0.jar 1000
                        Should contain  ${result}               Successfully stopped SparkContext
                        Should contain  ${result}               Pi is roughly 3.14

Calculate PI with spark (standalone cluster in client deploy mode)
    ${result} =         Execute on      master                  spark-submit --class org.apache.spark.examples.SparkPi --master spark://master:7077 --executor-memory 1G --total-executor-cores 5 /usr/local/spark/examples/jars/spark-examples_2.11-2.4.0.jar 1000
                        Should contain  ${result}               Successfully stopped SparkContext
                        Should contain  ${result}               Pi is roughly 3.14

Calculate PI with spark (standalone cluster in cluster deploy mode with supervise)
    ${result} =         Execute on          master                  spark-submit --class org.apache.spark.examples.SparkPi --master spark://master:7077 --deploy-mode cluster --supervise --executor-memory 1G --total-executor-cores 5 /usr/local/spark/examples/jars/spark-examples_2.11-2.4.0.jar 1000
                        Run                 sleep 30
                        Run                 vagrant scp slave-01:/usr/local/spark/work ./data/output
                        Run                 vagrant scp slave-02:/usr/local/spark/work ./data/output
                        Run                 vagrant scp slave-03:/usr/local/spark/work ./data/output
    ${drivererr} =      Run                 ls data/output/work/driver-*-*/stderr
    ${result} =         Grep File           ${drivererr}            Utils:
                        Should contain      ${result}               Successfully started service 'Driver'
    ${result} =         Grep File           ${drivererr}            SparkContext:
                        Should contain      ${result}               Successfully stopped SparkContext
    ${driverout} =      Run                 ls data/output/work/driver-*-*/stdout
    ${result} =         Grep File           ${driverout}            Pi
                        Should contain      ${result}               Pi is roughly 3.14
                        Remove Directory    data/output/work        recursive=True

#Launching driver driver-20190225104401-0000 on worker worker-20190225103944-10.10.10.201-38038

#Worker: Asked to launch driver driver-20190225104401-0000
#Worker: Driver driver-20190225104401-0000 exited successfully

Calculate PI with spark (on yarn in client mode)
    ${result} =         Execute on      master                  spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode client --executor-memory 2G --num-executors 5 /usr/local/spark/examples/jars/spark-examples_2.11-2.4.0.jar 1000
                        Should contain  ${result}               Successfully stopped SparkContext
                        Should contain  ${result}               Pi is roughly 3.14

Calculate PI with spark (on yarn in cluster mode)
    ${result} =         Execute on      master                  spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode cluster --executor-memory 2G --num-executors 5 /usr/local/spark/examples/jars/spark-examples_2.11-2.4.0.jar 1000
                        Should contain  ${result}               final status: SUCCEEDED
#                        Should contain  ${result}               Pi is roughly 3.14

# Run a Python application on a Spark standalone cluster

*** Keywords ***

Startup spark
                    ${stdout} =         Run                             vagrant up

Shutdown spark
                    ${stdout} =         Run                             vagrant destroy --force

Execute on
    [arguments]     ${componentname}    ${command}
    ${rc}           ${stdout} =         Run And Return Rc And Output    vagrant ssh ${componentname} -c "${command}"
    Should Be Equal As Integers         ${rc}                           0
    [return]        ${stdout}
