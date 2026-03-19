# T-Pot configuration changes for Microsoft Sentinel

The following instructions and sample data help to install 

### Microsoft Sentinel Configuration

To begin with you can deploy the Microsoft Sentinel prerequisites for collecting T-Pot’s data. You will send the events into a custom log using a Data Collection Rule (DCR) and a Data Collection Endpoint (DCE). The following steps below are derived from the following [documentation](https://learn.microsoft.com/en-us/azure/sentinel/connect-logstash-data-connection-rules#create-the-required-dcr-resources) regarding Logstash and DCR.

1.  [Create a Azure AD Application Registration](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-logs-ingestion-portal#create-azure-ad-application), copy the appid, tenant id, and generate a key secret and copy them for later usage.
    
2.  In the Resource Group of deployment click on Access Control (IAM) and add the Application Registration name from Step 1 earlier as a **_‘Monitoring Metrics Publisher’_** role, click review + assign.

### Azure VM T-Pot Configuration

The next steps will involve updating Azure VM T-Pot to install_microsoft-sentinel-logstash-output-plugin_ and configure the logstash.conf file for the new plugin to send data to Microsoft Sentinel.

1.  Using Putty or SSH user@AzTPotPublicIP:64295
    
2.  `sudo su`
    
3.  Run the following bash commands to enter Logstash docker bash, copy logstash.conf to /data mount on T-Pot VM and exit Logstash docker bash:
    
    ```
    docker exec -it logstash bash  
    cd /etc/logstash/  
    cp logstash.conf /tpotce/data/elk/logstash.conf  
    exit
    ```
    
4.  Stop tpot service:
    
    `systemctl stop tpot`
    
5.  modify the _/tpotce/data/elk/logstash.conf_ by scrolling close to the end and adding a second Output configuration for Microsoft Sentinel. Be sure to fill in the information collected from previous steps. an overall sample file can be found here: [logstash.conf](https://github.com/swiftsolves-msft/Azure-TPot/blob/main/sample/tpot_all/logstash.conf)
    
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
    
6. WARNING !!!! Still Figuring this out Modificatio may result in no logs sent to Sentinel !!! modify the _/tpotce/data/elk/logstash.conf_ by scrolling in **# Filter** section and making changes via remarks below. # CitrixHoneypot an overall sample file can be found here: [logstash.conf](https://github.com/swiftsolves-msft/Azure-TPot/blob/main/sample/tpot_all/logstash.conf)

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

7. WARNING !!!! Still Figuring this out Modificatio may result in no logs sent to Sentinel !!! modify the _/data/elk/logstash.conf_ by scrolling in a few sections and Remarking out via below. # ElasticPot, # Ipphoney, an overall sample file can be found here: [logstash.conf](https://github.com/swiftsolves-msft/Azure-TPot/blob/main/sample/tpot_all/logstash.conf)

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

```
    chmod 760 ~/tpotce/data/elk/logstash.conf  
    chown tpot:tpot ~/tpotce/data/elk/logstash.conf
```

9. In this next step you will now modify tpot.yml service file to install the Microsoft Sentinel plugin. with your editor edit the following file: _~/tpotce/docker-compose.yml_

10.  Scroll towrds bottom and remark # out the image and add the following lines with proper indents (two spaces). This will allow on next T-Pot service start to force a new image build using this information rather than pull the image from docker hub. It will also grab and use the copied and modified logstash.conf in /data you brought over and edited in the beginning of steps to use a Output plugin for Microsoft Sentinel.
    
```
## Logstash service
  logstash:
    container_name: logstash
    restart: always
    depends_on:
      elasticsearch:
        condition: service_healthy
    networks:
      - nginx_local
    environment:
      - LS_JAVA_OPTS=-Xms1024m -Xmx1024m
      - TPOT_TYPE=${TPOT_TYPE:-HIVE}
      - TPOT_HIVE_USER=${TPOT_HIVE_USER}
      - TPOT_HIVE_IP=${TPOT_HIVE_IP}
      - LS_SSL_VERIFICATION=${LS_SSL_VERIFICATION:-full}
    ports:
      - "127.0.0.1:64305:64305"
    mem_limit: 2g
    # image: $$   {TPOT_REPO}/logstash:   $${TPOT_VERSION}   # commented out as>
    build:
      context: ./docker/elk/logstash   # relative path (recommended over ~/)
      dockerfile: Dockerfile
    pull_policy: ${TPOT_PULL_POLICY}
    volumes:
      - ${TPOT_DATA_PATH}:/data
      - ./data/elk/logstash.conf:/etc/logstash/logstash.conf   # relative to do>
```

1.   Save the file and Next you will modify a Dockerfile for logstash at: _~/tpotce/docker/elk/logstash/Dockerfile_

2.   Insert the following line of code below the _bin/logstash-plugin update logstash-filter-translate &&_

```
    bin/logstash-plugin install microsoft-sentinel-logstash-output-plugin && \
```

13.  Save the file and then run: `systemctl start tpot`
    
14.  You can watch the tpot service live and look for logstash coming up by running `journalctl -u tpot.service -f`
    
15.  If you see some errors around logstash coming up in docker properly you can troubleshoot by running ` docker compose logs -f logstash | grep -i "sentinel\|error\|dns\|resolve\|ingest"` In my case it was a incoorect URI in `data_collection_endpoint => "https://tpotdce-nxxx.eastus2-1.ingest.monitor.azure.com"`