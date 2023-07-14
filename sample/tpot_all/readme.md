# T-Pot configuration changes for Micrsoft Sentinel

The following instructions and sample data help to install 

### Microsoft Sentinel Configuration

To begin with you can deploy the Microsoft Sentinel prerequisites for collecting T-Pot’s data. You will send the events into a custom log using a Data Collection Rule (DCR) and a Data Collection Endpoint (DCE). The following steps below are derived from the following [documentation](https://learn.microsoft.com/en-us/azure/sentinel/connect-logstash-data-connection-rules#create-the-required-dcr-resources) regarding Logstash and DCR.

1.  [Create a Azure AD Application Registration](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-logs-ingestion-portal#create-azure-ad-application), copy the appid, tenant id, and generate a key secret and copy them for later usage.
    
2.  [Create a Data Collection Endpoint](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-logs-ingestion-portal#create-data-collection-endpoint) by going to Azure Monitor and Data Collection Endpoints blade and adding a new DCE provide a name, in this example I called it ***tpotdce*** and deployed the DCE into a resource group where Log Analytics is also deployed. **Very important** after deployment go to the DCE Overview and **copy the Log Ingestion uri** , you will need this later in setup.
    
3.  [Create a new custom table that is DCR based](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-logs-ingestion-portal#create-new-table-in-log-analytics-workspace). Provide a table name in this example ***tpot***
    
4.  As part of the setup create a new data collection rule. In this example using a name ***tpotdcr*** and choose the DCE created in Step 2
    
5.  Next, on Schema and transformation [download the sample data file for tpot here](https://github.com/swiftsolves-msft/Azure-TPot/blob/main/sample/tpot/tpot-datasample.json): and Upload sample file.
    
6.  Click on Transformation Editor and add the following, run and apply
    
    source
    | extend TimeGenerated = todatetime(timestamp)
    | project-rename
        tpothostname = ['t-pot_hostname'],
        tpotextipaddr = ['t-pot_ip_ext'],
        tpotintipaddr = ['t-pot_ip_int'],
        tpottime = ['time'],
        tpotid = ['id'],
        tpotuuid = ['uuid'],
        honeypotType = type
    
7.  Click next and then create.
    
8.  Go to Azure Monitor and the Sata Collection Rules blade and select tpotdcr and click the JSON View in top right corner and copy the **immutableid**
    
9.  Copy the **streamDeclarations** json object name
    
10.  Click on Access Control (IAM) and add the Application Registration name from Step 1 earlier as a **_‘Monitoring Metrics Publisher’_** role, click review + assign.
    

### Azure VM T-Pot Configuration

The next steps will involve updating Azure VM T-Pot to install_microsoft-sentinel-logstash-output-plugin_ and configure the logstash.conf file for the new plugin to send data to Microsoft Sentinel.

1.  Log into CockPit service via https://AzTPotPublicIP:64294/system/terminal
    
2.  Click on the terminal tab and `sudo su`
    
3.  Run the following bash commands to enter Logstash docker bash, copy logstash.conf to /data mount on T-Pot VM and exit Logstash docker bash:
    
    `docker exec -it logstash bash  
    cd /etc/logstash/  
    cp logstash.conf /data/elk/logstash.conf  
    exit`
    
4.  Stop tpot service:
    
    `systemctl stop tpot`
    
5.  modify the _/data/elk/logstash.conf_ by scrolling close to the end and adding a second Output configuration for Microsoft Sentinel. Be sure to fill in the information collected from previous steps. an overall sample file can be found here: [logstash.conf](https://github.com/swiftsolves-msft/Azure-TPot/blob/main/sample/tpot_all/logstash.conf)
    
    `microsoft-sentinel-logstash-output-plugin {`
    
    `client_app_Id => ""`
    
    `client_app_secret => ""`
    
    `tenant_id => ""`
    
    `data_collection_endpoint => ""`
    
    `dcr_immutable_id => ""`
    
    `dcr_stream_name => "Custom-tpot_CL"`
    
    `compress_data => false`
    
    `create_sample_file=> false`
    
    `sample_file_path => "/data/temp"`
    
    `}`
    
6. modify the _/data/elk/logstash.conf_ by scrolling in a few sections making changes via remarks below. # CitrixHoneypot an overall sample file can be found here: [logstash.conf](https://github.com/swiftsolves-msft/Azure-TPot/blob/main/sample/tpot_all/logstash.conf)

    ```# CitrixHoneypot
    if [type] == "CitrixHoneypot" {
    	grok {
    		match => {
    			"message" => ["\A\(%{IPV4:src_ip:string}:%{INT:src_port:integer}\): %{JAVAMETHOD:http.http_method:string}%{SPACE}%{CISCO_REASON:fileinfo.state:string}: %{UNIXPATH:fileinfo.filename:string}",
    				"\A\(%{IPV4:src_ip:string}:%{INT:src_port:integer}\): %{JAVAMETHOD:http.http_method:string}%{SPACE}%{CISCO_REASON:fileinfo.state:string}: %{GREEDYDATA:payload:string}",
    				"\A\(%{IPV4:src_ip:string}:%{INT:src_port:integer}\): %{S3_REQUEST_LINE:msg:string} %{CISCO_REASON:fileinfo.state:string}: %{GREEDYDATA:payload:string:string}",
    				"\A\(%{IPV4:src_ip:string}:%{INT:src_port:integer}\): %{GREEDYDATA:msg:string}"
    			]
    		}
    	}
    	date {
    		match => ["asctime", "ISO8601"]
    		remove_field => ["asctime"]
    		remove_field => ["message"]
    	}
    	mutate {
    		add_field => {
    			"dest_port" => "443"
    		}
    		rename => {
    			"levelname" => "level"
    			"http.http_method" => "httpmethod" # Rename - ? , Grok earlier possible make change there.
    			"fileinfo.filename" => "fileinfoname" # Rename - ? , Grok earlier possible make change there.
    			"fileinfo.state" => "fileinfostate" # Rename - ? , Grok earlier possible make change there.
    		}
    	}
    }
    ```

7. modify the _/data/elk/logstash.conf_ by scrolling in a few sections and Remarking out via below. # ElasticPot, # Ipphoney, an overall sample file can be found here: [logstash.conf](https://github.com/swiftsolves-msft/Azure-TPot/blob/main/sample/tpot_all/logstash.conf)

```# ElasticPot
if [type] == "ElasticPot" {
	date {
		match => ["timestamp", "ISO8601"]
	}
	mutate {
		rename => {
			# "content_type" => "http.http_content_type"
			"dst_port" => "dest_port"
			"dst_ip" => "dest_ip"
			"message" => "event_type"
			"request" => "request_method"
			"user_agent" => "http_user_agent"
			# "url" => "http.url"
		}
	}
}
```

```# Ipphoney
if [type] == "Ipphoney" {
	date {
		match => ["timestamp", "ISO8601"]
	}
	mutate {
		rename => {
			"query" => "ipp_query"
			# "content_type" => "http.http_content_type"
			"dst_port" => "dest_port"
			"dst_ip" => "dest_ip"
			"request" => "request_method"
			"operation" => "data"
			"user_agent" => "http_user_agent"
			# "url" => "http.url"
		}
	}
}
```

8. Save the file and run the following to modify permissions to allow T-Pot service access.
    
    `chmod 760 /data/elk/logstash.conf  
    chown tpot:tpot /data/elk/logstash.conf`
    
9.  Next you will modify a Dockerfile for logstash at: _/opt/tpot/docker/elk/logstash/Dockerfile ,_
    
10.  Insert the following line of code below the _bin/logstash-plugin update_
    
    `bin/logstash-plugin install microsoft-sentinel-logstash-output-plugin && \`
    
11.  Save the file and in this next step you will now modify tpot.yml service file to install the Microsoft Sentinel plugin. with your editor edit the following file: _/opt/tpot/etc/tpot.yml_
    
12.  remark # out the image and add the following lines with proper indents (two spaces). This will allow on next T-Pot service start to force a new image build using this information rather than pull the image from docker hub. It will also grab and use the copied and modified logstash.conf in /data you brought over and edited in the beginning of steps to use a Output plugin for Microsoft Sentinel.
    
    `## Logstash service`
    
    `logstash:`
    
    **_build:_**
    
    **_context: /opt/tpot/docker/elk/logstash_**
    
    **_dockerfile: ./Dockerfile_**
    
    `container_name: logstash`
    
    `restart: always`
    
    `environment:`
    
    `- LS_JAVA_OPTS=-Xms1024m -Xmx1024m`
    
    `depends_on:`
    
    `elasticsearch:`
    
    `condition: service_healthy`
    
    `env_file:`
    
    `- /opt/tpot/etc/compose/elk_environment`
    
    `mem_limit: 2g`
    
    **_# image: "dtagdevsec/logstash:2204"_**
    
    `volumes:`
    
    `- /data:/data`
    
    **_- /data/elk/logstash.conf:/etc/logstash/logstash.conf_**
    
12.  Save the file and then run: `systemctl start tpot`
    
13.  In the CockPit service go to Services and scroll down to tpot service and goto All Logs - ensure the tpot service launches correctly without obvious errors on LogStash docker container. below are some signs of successful launch with new modifications

![enter image description here](https://raw.githubusercontent.com/swiftsolves-msft/Azure-TPot/main/images/tpotload1.png)

![enter image description here](https://raw.githubusercontent.com/swiftsolves-msft/Azure-TPot/main/images/tpotload2.png)
