## HTML Layout View - DIV TAG details ##
# 1.HeaderArea
# 2.LogArea
# 3.WorkArea
#   a.AuthenticationArea
#   b.ContentArea
#        i. NavigationArea
#		 ii.ProjectDetailsArea
#		 iii.TopologyCreateArea
#		 iv. TopologyViewArea
#		 v. TopologyDeleteArea
#		 vi. DeviceConfigArea
#		 vii.DeviceStatisticsArea
#		 viii.CustomConfigArea.
##			

#global parameters
controllerurl = "http://localhost:8888"

projectid = null
passcode = null
projectdata = {}

authenticated = false
TopologyExists = false
#TopologyData = {}

Topologyid = null
Topologystatus = null
Topology = {}
nodes = []
switches = []
nodenames = []
links = []
devices = []



#Dynamically populated view data
projectview_data = null
topologyview_data = null

#Hide/shiw Div view functions....make sure views are doesnt manipulated in other functions

hideAllMainViews = ()->
	$("#HeaderArea").hide()	
	$("#WorkArea").hide()
	$("#LogArea").hide()

hideAllWorkAreaSubviews = ()->
	$("#AuthenticationArea").hide()
	$("#ContentArea").hide()

hideAllContentAreaSubviews = ()->	
	#$("NavigationArea").hide() --- we dont want to hide navigation view 
	$("#ProjectDetailsArea").hide()
	$("#TopologyCreateArea").hide()
	$("#TopologyViewArea").hide()
	$("#TopologyDeleteArea").hide()
	$("#DeviceConfigArea").hide()
	$("#DeviceStatisticsArea").hide()
	$("#CustomConfigArea").hide()

#----------------------------------------------------------------------------------
LoginView = ()->	
	hideAllMainViews()	
	hideAllWorkAreaSubviews()
	hideAllContentAreaSubviews()
	$("#HeaderArea").show()
	$("#WorkArea").show()	
	$("#AuthenticationArea").show()

ShowMainViews = ()->
	hideAllWorkAreaSubviews()
	hideAllMainViews()	
	hideAllContentAreaSubviews()
	$("#HeaderArea").show()
	$("#WorkArea").show()	
	$("#LogArea").show()		
	$("#ContentArea").show()
	hideAllContentAreaSubviews()
	$("#NavigationArea").show()

##main routine
$ ->
	$( "#NavigationArea" ).accordion
		collapsible: true
		heightStyle: "content"

	$("#devicestatistics_tabs").tabs()
	debuglog "DOM is ready"
	#show the login screen
	LoginView()


	$("#projectdetailslink").click ()=>
		hideAllContentAreaSubviews()		
		if projectview_data is null
			populateprojectdetails()
			$("#ProjectDetailsArea").append projectview_data
		$("#ProjectDetailsArea").show()
	
	$("#createtopologylink").click ()=>
		hideAllContentAreaSubviews()
		getExistingTopology()
		if TopologyExists is false
			$("#TopologyCreateArea").show()		

	

	$("#viewtopologylink").click ()=>		
		hideAllContentAreaSubviews()
		#if topologyview_data is null
		populateViewTopologyDetails()
			#$("#TopologyViewArea").append topologyview_data
		$("#TopologyViewArea").show()
		
		
	$("#deletetopologylink").click ()=>
		hideAllContentAreaSubviews()
		deleteTopology()
		$("#TopologyDeleteArea").show()
		

	$("#deviceconfiglink").click ()=>
		hideAllContentAreaSubviews()		
		$("#DeviceConfigArea").show()		

	$("#devicestatuslink").click ()=>
		hideAllContentAreaSubviews()		
		$("#DeviceStatusArea").show()		

	$("#devicestatisticslink").click ()=>
		hideAllContentAreaSubviews()
		$("#DeviceStatisticsArea").show()
		
	$("#linkprofilelink").click ()=>
		hideAllContentAreaSubviews()
		$("#CustomConfigArea").show()
		
#utility function

log = $("#tablelog")
debuglog = (mytext)->
	$("#tablelog").append "<p>" + mytext + "<p>"


#Auth routine and populate the project routine----------------------------------
authenticate = ()->
	console.log "authenticate called"
	projectid = $("#projectid").val() 
	passcode = $("#passcode").val()			
	url = "http://localhost:2222/project/"+projectid+"/passcode/"+passcode
	debuglog "authentication url is " + url
	$.getJSON url, (result)=>
		if result.data?
			authenticated = true						
			debuglog "project data  " + JSON.stringify result.data
			projectdata = result.data			
			ShowMainViews()
			getExistingTopology()
		else
			debuglog "unknown project id"

populateprojectdetails = ()->
	projectview_data = "<table>"
	for key,val of projectdata
		projectview_data += "<tr><td>#{key}</td><td>#{val}</td></tr>"
	projectview_data += "</table>"
	debuglog "projectview_data " + projectview_data
#---------------------------------------------------------------------------------

getExistingTopology = ()->
	return if authenticated is false
	url = controllerurl+"/project/"+projectid
	debuglog "get project topology url is " + url
	$.getJSON url, (result)=>
		debuglog "getTopology result is " + JSON.stringify result
		#response is array
		if result[0]?.data?
			TopologyExists = true
			Topologyid = result[0].id
			debuglog "Topology id " + Topologyid			
			debuglog "Topology Exists"
			#debuglog "Topo data  " + JSON.stringify TopologyData			
		else
			TopologyExists = false
			debuglog "No Topology Exists"

populateViewTopologyDetails = ()->
	$("#TopologyViewArea").empty()

	unless Topologyid?	
		debuglog "Topology doesnt exists ... Please create a Topology " + Topologyid
		$("#TopologyViewArea").append "<H1 > No associated Topology available for this project. Please create one for you <H1>"
		return

	url = controllerurl + "/topology/" + Topologyid + "/status"
	debuglog "get  topology  status url is " + url	
	$.getJSON url, (result)=>
		debuglog "getTopology status result is " + JSON.stringify result
		topologyview_data = "<table><tr><td>UUID</td><td>Name</td><td>Type</td><td>MgmtIP</td><td>status</td></tr>"
		devices = result.nodes
		for node in result.nodes
			debuglog "node is " + JSON.stringify node
			topologyview_data += "<tr>"
			for key,val of node
				topologyview_data += "<td>#{val}</td>"if key is "id"
				if key is "config"
					topologyview_data += "<td>#{val.name}</td>"					
					topologyview_data += "<td>#{val.type}</td>"
					###
					if key is "ifmap"					
						for ifm in val
							for keyy, vall of ifm
								ipa = val if keyy is "ipaddress"
								type = val	if keyy is "type"
								if type is "mgmt"
									formatop += ip
									break
					###
				if key is "status"
					topologyview_data += "<td>#{val.result}</td>"
				#debuglog "name :" +  val.name if key is "config"
				#debuglog "status :" +  val.result if key is "status"

				Topologystatus = val.result
			topologyview_data += "</tr>"
		topologyview_data += "</table>"
		debuglog "topologyview_data " + topologyview_data
		$("#TopologyViewArea").append topologyview_data
		#setTopologyStatusWidget()
		#setViewTopologyView formatop

populateDeviceConfigView = ()->

populateDeviceStatusView = ()->
	#query the individual device and device status

populateDeviceStatisticsView = ()->
	#query individual device statistics

	



#Topology creation routines
#--------------------------------------------------------------------------------------
populateDevices = ()->
	noofswitches = $("#switches").val()
	noofrouters = $("#routers").val()
	noofhosts = $("#hosts").val()
	debuglog "No of Switches " + noofswitches
	debuglog "No of Routers " + noofrouters
	debuglog "No of Hosts " + noofhosts
	i = 0
	while i < noofswitches 
		sw = 
			"name" : projectid + "Sw" + i
			"type" : "lan"
			"ports" : "8"
			"make"  : "bridge"
		switches.push sw
		i++

	j = 0
	while j < noofrouters 
		node =
			name : projectid + "Rtr" + j
			type : "router"
			Services :  [
				{name : "quagga"}
			]
		nodes.push node
		nodenames.push node.name
		j++

	i = 0
	while i < noofhosts
		node =
			"name" : projectid + "Host" + i
			"type" : "host"			
		nodes.push node
		nodenames.push node.name
		i++
	debuglog "Switches " +  JSON.stringify switches
	debuglog "Nodes " +  JSON.stringify nodes
	debuglog "NodeNames " + nodenames


	#auto complete routine for Link From/To Nodes
	$("#fromdevice").autocomplete
	 	source: nodenames
	$("#todevice").autocomplete
	 	source: nodenames

	#set Topology information 
	$("#routernames").val(nodenames)
	

addLink = ()->
	connected_nodes = []
	linkconfig =
        "bandwidth":"256kbit",
        "latency": "100ms",
        "jitter":"10ms",
        "pktloss": "2%"

    srcname = $("#fromdevice").val()
    dstname = $("#todevice").val()
    connected_nodes.push
    	"name" : srcname
    	#"name" : $("#fromdevice").val()
    connected_nodes.push
    	"name" : dstname
    	#"name" : $("#todevice").val()
      
	link =
		type : "wan"
		switch : ""
		connected_nodes : connected_nodes
		"config" : linkconfig
		
	links.push link
	debuglog "link val is " + JSON.stringify link

	temp = $("#linknames").val()
	temp = temp + ", #{srcname}-#{dstname}"
	$("#linknames").val(temp)



createTopology = ()->
	Topology = 
		name		: $("#toponame").val()
		projectid : projectid
		passcode  : passcode
		switches	: switches
		nodes		: nodes
		links		: links
	debuglog "Topology object " + JSON.stringify Topology
	$.ajax
		url: controllerurl + "/topology"
		type: "post"
		data: Topology
		error: (jqXHR, textStatus, errorThrown)->
			debuglog "Error Response"
			debuglog JSON.stringify jqXHR
			debuglog JSON.stringify textStatus
			debuglog JSON.stringify errorThrown
			return
		success: (data, textStatus, jqXHR)->
			debuglog "Topology Creation success Response"
			#debuglog JSON.stringify jqXHR
			#debuglog JSON.stringify textStatus
			debuglog JSON.stringify data
			Topologyid = data.id
			setTopologyIdwidget()
			Topologystatus = "creation-in-progress"
			setTopologyStatusWidget()	
			return
#Topology creation routine ends.-------------------------------------------------------------------------



deleteTopology = ()->
	debuglog "Topology delete called  ..." + Topologyid
	unless Topologyid?
		debuglog "Topology doesnt exists ... Please create a Topology " + Topologyid	
	delurl = controllerurl + "/topology/" + Topologyid 
	debuglog "Topology delete called  ..." + delurl
	$.ajax
		url: delurl
		type: "DELETE"		
		error: (jqXHR, textStatus, errorThrown)->
			debuglog "Error Response"
			debuglog JSON.stringify jqXHR
			debuglog JSON.stringify textStatus
			debuglog JSON.stringify errorThrown
			return
		success: (data, textStatus, jqXHR)->
			debuglog "Topology Detele success Response"
			#debuglog JSON.stringify jqXHR
			#debuglog JSON.stringify textStatus
			debuglog JSON.stringify data
			Topologyid = null
			return







#Widget updates
setTopologyIdwidget = ()->
	$("#topologyid").val(Topologyid)
	$("#tbltd_topologyid").append '<p>#{Topologyid}</p>'
	

setTopologyStatusWidget = ()->
	$("#topologystatus").val(Topologystatus)

setViewTopologyView = (value) ->
	debuglog "value is " + value
	$("#tbltrdevicestatus").append value


