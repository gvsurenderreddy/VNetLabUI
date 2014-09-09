#global parameters
controllerurl = "http://localhost:8888"
projectid = null
passcode = null
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

#Hide/shiw Div view functions
LoginView = ()->	
	hideallviews()
	#$("#headingarea").show()
	$("#headingarea").show()
	$("#workarea").show()
	$("#workarea1").hide()
	$("#autharea").show()
	$("#logarea").show()


hideallviews = ()->
	$("#headingarea").hide()	
	$("#workarea").hide()
	$("#logarea").hide()



hideWorkareaViews = ()->	
	$("createtopologyarea").hide()
	$("viewtopologyarea").hide()
	#$("#topocreate").hide()
	#$("#topoview").hide()
	#$("#devices").hide()


showmainviews = ()->
	hideallviews()
	$("#autharea").hide()
	$("#headingarea").show()
	$("#workarea").show()	
	$("#logarea").show()		
	$("#workarea1").show()
	$("#navarea").show()
	$("#createtopologyarea").hide()
	$("#viewtopologyarea").hide()
	#hideWorkareaViews()

##main routine
$ ->
	$( "#navarea" ).accordion
		collapsible: true
		heightStyle: "content"
	debuglog "DOM is ready"
	#show the login screen
	LoginView()



	$("#createtopolink").click ()=>
		hideWorkareaViews()
		getExistingTopology()
		if TopologyExists is false
			$("#createtopologyarea").show()

	$("#viewtopolink").click ()=>		
		$("#createtopologyarea").hide()
		$("#viewtopologyarea").show()
		viewTopology()
		#hideWorkareaViews()
		#$("#topoview").show()
	$("#deletetopolink").click ()=>
		deleteTopology()

	$("#devicestatuslink").click ()=>
		hideWorkareaViews()
		$("#devices").show()		
	$("#deviceviewlink").click ()=>
		hideWorkareaViews()
	$("#configviewlink").click ()=>
		hideWorkareaViews()


log = $("#tablelog")
debuglog = (mytext)->
	#newDate = new Date();
	#datetime = "LastSync: " + newDate.today() + " @ " + newDate.timeNow()
	$("#tablelog").append "<p>" + mytext + "<p>"
	#$("#topodetails").children("p").text(x + mytext )
#Auth routine
authenticate = ()->
	projectid = $("#projectid").val() 
	passcode = $("#passcode").val()			
	url = "http://localhost:2222/project/"+projectid+"/passcode/"+passcode
	debuglog "authentication url is " + url
	$.getJSON url, (result)=>
		if result.data?
			authenticated = true						
			debuglog "project data  " + JSON.stringify result.data
			showmainviews()
			getExistingTopology()
		else
			debuglog "unknown project id"
			
	#check whether the topology exists for this projectid
	#getTopology() 
	

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
			#TopologyData = result[0].data
			debuglog "Topology Exists"
			#debuglog "Topo data  " + JSON.stringify TopologyData
			
		else
			TopologyExists = false

			debuglog "No Topology Exists"
	
populateDevices = ()->
	noofswitches = $("#switches").val()
	noofrouters = $("#routers").val()
	noofhosts = $("#hosts").val()
	debuglog "No of Switches " + noofswitches
	debuglog "No of Routers " + noofrouters
	debuglog "No of Hosts " + noofhosts
	#printTopologyData "No of Switches " + noofswitches
	#printTopologyData  "No of Routers " + noofrouters
	#printTopologyData  "No of Hosts " + noofhosts

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

viewTopology = ()->
	unless Topologyid?
		debuglog "Topology doesnt exists ... Please create a Topology " + Topologyid
		$("#viewtopologyarea").add("<H1> No associated Topology available for this project. Please create one for you <H1>")

	url = controllerurl + "/topology/" + Topologyid + "/status"
	debuglog "get  topology  status url is " + url	
	$.getJSON url, (result)=>
		debuglog "getTopology status result is " + JSON.stringify result
		formatop = "<td>Name</td><td>id</td><td>type</td><td>MgmtIP</td><td>status</td><br>"
		for node in result.nodes
			debuglog "node is " + JSON.stringify node
			formatop += "<tr>"
			for key,val of node
				formatop += "<td>#{val}</td>"if key is "id"
				if key is "config"
					formatop += "<td>#{val.name}</td>"					
					formatop += "<td>#{val.type}</td>"
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
					formatop += "<td>#{val.result}</td>"
				#debuglog "name :" +  val.name if key is "config"
				#debuglog "status :" +  val.result if key is "status"

				Topologystatus = val.result
			formatop += "</tr>"
		debuglog "formatop " + formatop

		setTopologyStatusWidget()
		setViewTopologyView formatop

		

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

setViewTopologyView = (value)->
	$("#tbltr_devicestatus").append value


