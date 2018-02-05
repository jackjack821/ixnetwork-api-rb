# -*- coding: cp1252 -*-
################################################################################
#                                                                              #
#    Copyright © 1997 - 2017 by IXIA                                           #
#    All Rights Reserved.                                                      #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
#                                LEGAL  NOTICE:                                #
#                                ==============                                #
# The following code and documentation (hereinafter "the script") is an        #
# example script for demonstration purposes only.                              #
# The script is not a standard commercial product offered by Ixia and have     #
# been developed and is being provided for use only as indicated herein. The   #
# script [and all modifications enhancements and updates thereto (whether      #
# made by Ixia and/or by the user and/or by a third party)] shall at all times #
# remain the property of Ixia.                                                 #
#                                                                              #
# Ixia does not warrant (i) that the functions contained in the script will    #
# meet the users requirements or (ii) that the script will be without          #
# omissions or error-free.                                                     #
# THE SCRIPT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND AND IXIA         #
# DISCLAIMS ALL WARRANTIES EXPRESS IMPLIED STATUTORY OR OTHERWISE              #
# INCLUDING BUT NOT LIMITED TO ANY WARRANTY OF MERCHANTABILITY AND FITNESS FOR #
# A PARTICULAR PURPOSE OR OF NON-INFRINGEMENT.                                 #
# THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SCRIPT  IS WITH THE #
# USER.                                                                        #
# IN NO EVENT SHALL IXIA BE LIABLE FOR ANY DAMAGES RESULTING FROM OR ARISING   #
# OUT OF THE USE OF OR THE INABILITY TO USE THE SCRIPT OR ANY PART THEREOF     #
# INCLUDING BUT NOT LIMITED TO ANY LOST PROFITS LOST BUSINESS LOST OR          #
# DAMAGED DATA OR SOFTWARE OR ANY INDIRECT INCIDENTAL PUNITIVE OR              #
# CONSEQUENTIAL DAMAGES EVEN IF IXIA HAS BEEN ADVISED OF THE POSSIBILITY OF    #
# SUCH DAMAGES IN ADVANCE.                                                     #
# Ixia will not be required to provide any software maintenance or support     #
# services of any kind (e.g. any error corrections) in connection with the     #
# script or any part thereof. The user acknowledges that although Ixia may     #
# from time to time and in its sole discretion provide maintenance or support  #
# services for the script any such services are subject to the warranty and    #
# damages limitations set forth herein and will not obligate Ixia to provide   #
# any additional maintenance or support services.                              #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
# Description:                                                                 #
#    This script intends to demonstrate how to use NGPF StaticLag API.         #
#     Script uses four ports to demonstrate LAG properties                     #
#                                                                              #
#    1. It will create 2 StaticLag topologies, each having two ports which are #
#       LAG members. It will then modify the Lag Id for both the LAG systems   #
#    2. Start the StaticLag protocol.                                          #
#    3. Retrieve protocol statistics and StaticLag per port statistics         #
#    4. Perform Simulate Link Down on port1 in System1-StaticLag-LHS           #
#    5. Retrieve protocol statistics, StaticLag per port statistics            #
#    6. Retrieve StaticLag global learned info                                 #
#    7. Perform Simulate Link Up on port1 in System1-StaticLag-LHS             #
#    8. Retrieve protocol statistics and StaticLag per port statistics         #
#    9. Retrieve StaticLag global learned info                                 #
#    10. Stop All protocols                                                    #
#                                                                              #
################################################################################

def assignPorts (ixNet, realPort1, realPort2, realPort3, realPort4)
    chassis1 = realPort1[0]
    chassis2 = realPort2[0]
    card1    = realPort1[1]
    card2    = realPort2[1]
    port1    = realPort1[2]
    port2    = realPort2[2]
    chassis3 = realPort3[0]
    chassis4 = realPort4[0]
    card3    = realPort3[1]
    card4    = realPort4[1]
    port3    = realPort3[2]
    port4    = realPort4[2]

    root = @ixNet.getRoot()
    vport1 = @ixNet.add(root, 'vport')
    @ixNet.commit()
    vport1 = @ixNet.remapIds(vport1)[0]

    vport2 = @ixNet.add(root, 'vport')
    @ixNet.commit()
    vport2 = @ixNet.remapIds(vport2)[0]

    vport3 = @ixNet.add(root, 'vport')
    @ixNet.commit()
    vport3 = @ixNet.remapIds(vport3)[0]

    vport4 = @ixNet.add(root, 'vport')
    @ixNet.commit()
    vport4 = @ixNet.remapIds(vport4)[0]

    chassisObj1 = @ixNet.add(root + '/availableHardware', 'chassis')
    @ixNet.setAttribute(chassisObj1, '-hostname', chassis1)
    @ixNet.commit()
    chassisObj1 = @ixNet.remapIds(chassisObj1)[0]

    if (chassis1 != chassis2) then
        chassisObj2 = @ixNet.add(root + '/availableHardware', 'chassis')
        @ixNet.setAttribute(chassisObj2, '-hostname', chassis2)
        @ixNet.commit()
        chassisObj2 = @ixNet.remapIds(chassisObj2)[0]

        chassisObj3 = @ixNet.add(root + '/availableHardware', 'chassis')
        @ixNet.setAttribute(chassisObj3, '-hostname', chassis3)
        @ixNet.commit()
        chassisObj3 = @ixNet.remapIds(chassisObj2)[0]

        chassisObj4 = @ixNet.add(root + '/availableHardware', 'chassis')
        @ixNet.setAttribute(chassisObj4, '-hostname', chassis4)
        @ixNet.commit()
        chassisObj4 = @ixNet.remapIds(chassisObj4)[0]
    else
        chassisObj2 = chassisObj1
        chassisObj3 = chassisObj1
        chassisObj4 = chassisObj1

    end

    cardPortRef1 = chassisObj1 + '/card:'+card1+'/port:'+port1
    @ixNet.setMultiAttribute(vport1, '-connectedTo', cardPortRef1,
    '-rxMode', 'captureAndMeasure', '-name', 'Ethernet - 001')
    @ixNet.commit()

    cardPortRef2 = chassisObj2 + '/card:'+card2+'/port:'+port2
    @ixNet.setMultiAttribute(vport2, '-connectedTo', cardPortRef2,
    '-rxMode', 'captureAndMeasure', '-name', 'Ethernet - 002')
    @ixNet.commit()

    cardPortRef3 = chassisObj3 + '/card:'+card3+'/port:'+port3
    @ixNet.setMultiAttribute(vport3, '-connectedTo', cardPortRef3,
    '-rxMode', 'captureAndMeasure', '-name', 'Ethernet - 003')
    @ixNet.commit()

    cardPortRef4 = chassisObj4 + '/card:'+card4+'/port:'+port4
    @ixNet.setMultiAttribute(vport4, '-connectedTo', cardPortRef4,
    '-rxMode', 'captureAndMeasure', '-name', 'Ethernet - 004')
    @ixNet.commit()
end

#proc to generate drill-down global learned info view for Static LAG
def gererateStaticLagLearnedInfoView ( viewName )
    viewCaption = viewName
    protocol = 'Static LAG'
    drillDownType = 'Global Learned Info'
    root    = @ixNet.getRoot()
    statistics = root + '/statistics'
    statsViewList = @ixNet.getList(statistics, 'view')

    # Add a StatsView
    view = @ixNet.add(statistics, 'view')
    @ixNet.setAttribute(view, '-caption', viewCaption)
    @ixNet.setAttribute(view, '-type', 'layer23NextGenProtocol')
    @ixNet.setAttribute(view, '-visible', 'true')
    @ixNet.commit()
    view = @ixNet.remapIds(view)[0]

    # Set Filters
    trackingFilter = @ixNet.add(view, 'advancedCVFilters')
    @ixNet.setAttribute(trackingFilter, '-protocol', protocol)
    @ixNet.commit()
    #ixNet getAttr $trackingFilter -availableGroupingOptions
    @ixNet.setAttribute(trackingFilter, '-grouping', drillDownType)
    @ixNet.commit()
    layer23NextGenProtocolFilter = view + '/' + 'layer23NextGenProtocolFilter'
    @ixNet.setAttribute(layer23NextGenProtocolFilter, '-advancedCVFilter', trackingFilter)
    @ixNet.commit()

    # Enable Stats Columns to be displayed
    statsList = @ixNet.getList(view, 'statistic')
    for stat in statsList
        @ixNet.setAttribute(stat, '-enabled', 'true')
    end
    @ixNet.commit()

    # Enable Statsview
    @ixNet.setAttribute(view, '-enabled', 'true')
    @ixNet.commit()
end

################################################################################
# Import the ixnetwork library
# First add the library to Ruby's $LOAD_PATH:    $:.unshift <library_dir>
################################################################################
require 'ixnetwork'

#################################################################################
# Give chassis/client/ixNetwork server port/ chassis port HW port information
# below
#################################################################################
ixApiServer = '10.200.115.203'
ixApiPort   = '8009'
ports       = [['10.200.115.151', '4', '1'], ['10.200.115.151', '4', '2'], ['10.200.115.151', '4', '3'], ['10.200.115.151', '4', '4']]

# get IxNet class
@ixNet = IxNetwork.new
puts("Connecting to IxNetwork client")
@ixNet.connect(ixApiServer, '-port', ixApiPort, '-version', '7.50',
'-setAttribute', 'strict')

# cleaning up the old config, and creating an empty config
puts("Cleaning up the old config file, and creating an empty config")
@ixNet.execute('newConfig')

# assigning ports
assignPorts(@ixNet, ports[0], ports[1], ports[2], ports[3])
sleep(5)

root    = @ixNet.getRoot()
vportTx1 = @ixNet.getList(root, 'vport')[0]
vportRx1 = @ixNet.getList(root, 'vport')[1]
vportTx2 = @ixNet.getList(root, 'vport')[2]
vportRx2 = @ixNet.getList(root, 'vport')[3]
vportListLAG1 = [vportTx1, vportTx2]
vportListLAG2 = [vportRx1, vportRx2]

puts("Adding topologies")
@ixNet.add(root, 'topology', '-vports', vportListLAG1)
@ixNet.add(root, 'topology', '-vports', vportListLAG2)
@ixNet.commit()

topologies = @ixNet.getList(@ixNet.getRoot(), 'topology')
topo1 = topologies[0]
topo2 = topologies[1]

puts "Adding 2 device groups"
@ixNet.add(topo1, 'deviceGroup')
@ixNet.add(topo2, 'deviceGroup')
@ixNet.commit()

t1devices = @ixNet.getList(topo1, 'deviceGroup')
t2devices = @ixNet.getList(topo2, 'deviceGroup')

t1dev1 = t1devices[0]
t2dev1 = t2devices[0]

puts("Configuring the multipliers (number of sessions)")
@ixNet.setAttribute(t1dev1, '-multiplier', '1')
@ixNet.setAttribute(t2dev1, '-multiplier', '1')
@ixNet.commit()

puts("Adding ethernet/mac endpoints")
@ixNet.add(t1dev1, 'ethernet')
@ixNet.add(t2dev1, 'ethernet')
@ixNet.commit()

mac1 = @ixNet.getList(t1dev1, 'ethernet')[0]
mac2 = @ixNet.getList(t2dev1, 'ethernet')[0]

puts("Configuring the mac addresses %s" % (mac1))
@ixNet.setMultiAttribute(@ixNet.getAttribute(mac1, '-mac') + '/counter',
'-direction', 'increment',
'-start',     '00:11:01:00:00:01',
'-step',      '00:00:01:00:00:00')

@ixNet.setMultiAttribute(@ixNet.getAttribute(mac2, '-mac') + '/counter',
'-direction', 'increment',
'-start',     '00:12:01:00:00:01',
'-step',      '00:00:01:00:00:00')
@ixNet.commit()

puts("Adding StaticLag over Ethernet stacks")
@ixNet.add(mac1, 'staticLag')
@ixNet.add(mac2, 'staticLag')
@ixNet.commit()

statLag1 = @ixNet.getList(mac1, 'staticLag')[0]
statLag1 = @ixNet.getList(mac2, 'staticLag')[0]

puts("Renaming the topologies and the device groups")
@ixNet.setAttribute(topo1, '-name', 'LAG1-LHS')
@ixNet.setAttribute(topo2, '-name', 'LAG1-RHS')

@ixNet.setAttribute(t1dev1, '-name', 'SYSTEM1-StaticLag-LHS')
@ixNet.setAttribute(t2dev1, '-name', 'SYSTEM1-StaticLag-RHS')
@ixNet.commit()

puts("Modifying lagId to user defined values")
sys1LagLHS = @ixNet.getList(mac1, 'staticLag')[0]
sys1LagRHS = @ixNet.getList(mac2, 'staticLag')[0]

sys1LagLHSport1 = @ixNet.getList(sys1LagLHS, 'port')[0]
sys1LagLHSport2 = @ixNet.getList(sys1LagLHS, 'port')[1]
sys1LagRHSport1 = @ixNet.getList(sys1LagRHS, 'port')[0]
sys1LagRHSport2 = @ixNet.getList(sys1LagRHS, 'port')[1]

sys1LagLHSport1lagId = @ixNet.getAttribute(sys1LagLHSport1, '-lagId')
sys1LagLHSport2lagId = @ixNet.getAttribute(sys1LagLHSport2, '-lagId')
sys1LagRHSport1lagId = @ixNet.getAttribute(sys1LagRHSport1, '-lagId')
sys1LagRHSport2lagId = @ixNet.getAttribute(sys1LagRHSport2, '-lagId')

@ixNet.setMultiAttribute(sys1LagLHSport1lagId, '-pattern', 'singleValue', '-clearOverlays', 'false')
@ixNet.setMultiAttribute(sys1LagLHSport2lagId, '-pattern', 'singleValue', '-clearOverlays', 'false')
@ixNet.setMultiAttribute(sys1LagRHSport1lagId, '-pattern', 'singleValue', '-clearOverlays', 'false')
@ixNet.setMultiAttribute(sys1LagRHSport2lagId, '-pattern', 'singleValue', '-clearOverlays', 'false')
@ixNet.commit()

@ixNet.setMultiAttribute(sys1LagLHSport1lagId + '/singleValue', '-value', '666')
@ixNet.setMultiAttribute(sys1LagLHSport2lagId + '/singleValue', '-value', '666')
@ixNet.setMultiAttribute(sys1LagRHSport1lagId + '/singleValue', '-value', '777')
@ixNet.setMultiAttribute(sys1LagRHSport2lagId + '/singleValue', '-value', '777')
@ixNet.commit()

################################################################################
# Start StaticLag protocol and wait for 60 seconds                             #
################################################################################
puts("Starting StaticLag and waiting for 60 seconds for sessions to come up")
@ixNet.execute('startAllProtocols')
sleep(60)

################################################################################
# Retrieve protocol statistics and Static LAG Per Port statistics              #
################################################################################
puts("\nFetching all Protocol Summary Stats\n")
viewPage  = '::ixNet::OBJ-/statistics/view:"Protocols Summary"/page'
statcap   = @ixNet.getAttribute(viewPage, '-columnCaptions')
for statValList in @ixNet.getAttribute(viewPage, '-rowValues')
    for  statVal in statValList
        puts("***************************************************")
        index = 0
        for satIndv in statVal
            puts(statcap[index]+' '+satIndv)
            index = index + 1
        end
    end
end
puts("***************************************************")

puts("\nFetching all Static LAG Per Port Stats\n")
viewPage  = '::ixNet::OBJ-/statistics/view:"Static LAG Per Port"/page'
statcap   = @ixNet.getAttribute(viewPage, '-columnCaptions')
for statValList in @ixNet.getAttribute(viewPage, '-rowValues')
    for  statVal in statValList
        puts("***************************************************")
        index = 0
        for satIndv in statVal
            puts(statcap[index]+' '+satIndv)
            index = index + 1
        end
    end
end
puts("***************************************************")

sleep(5)
################################################################################
# Perform Simulate Link Down on port1 in System1-StaticLag-LHS                 #
################################################################################
puts("\n\nPerform Simulate Link Down on port1 in System1-StaticLag-LHS ")
@ixNet.execute('linkUpDn', vportTx1, 'down')
sleep(5)
################################################################################
# Retrieve protocol statistics                                                 #
################################################################################
puts("\nFetching all Protocol Summary Stats\n")
viewPage  = '::ixNet::OBJ-/statistics/view:"Protocols Summary"/page'
statcap   = @ixNet.getAttribute(viewPage, '-columnCaptions')
for statValList in @ixNet.getAttribute(viewPage, '-rowValues')
    for  statVal in statValList
        puts("***************************************************")
        index = 0
        for satIndv in statVal
            puts(statcap[index]+' '+satIndv)
            index = index + 1
        end
    end
end
puts("***************************************************")
puts("\nFetching all Static LAG Per Port Stats\n")
viewPage  = '::ixNet::OBJ-/statistics/view:"Static LAG Per Port"/page'
statcap   = @ixNet.getAttribute(viewPage, '-columnCaptions')
for statValList in @ixNet.getAttribute(viewPage, '-rowValues')
    for  statVal in statValList
        puts("***************************************************")
        index = 0
        for satIndv in statVal
            puts(statcap[index]+' '+satIndv)
            index = index + 1
        end
    end
end
puts("***************************************************")
sleep(5)
################################################################################
# Retrieve StaticLag global Learned Info                                         #
################################################################################
puts("\n\n Retrieve StaticLag global Learned Info\n")
viewName = 'StaticLag-global-learned-Info-APIview'
gererateStaticLagLearnedInfoView(viewName)
viewPageName = '::ixNet::OBJ-/statistics/view:"StaticLag-global-learned-Info-APIview"'
viewPage  = '::ixNet::OBJ-/statistics/view:"StaticLag-global-learned-Info-APIview"/page'

@ixNet.execute('refresh', viewPageName)
sleep(10)
statcap   = @ixNet.getAttribute(viewPage, '-columnCaptions')
for statValList in @ixNet.getAttribute(viewPage, '-rowValues')
    for  statVal in statValList
        puts("***************************************************")
        index = 0
        for satIndv in statVal
            puts(statcap[index]+' '+satIndv)
            index = index + 1
        end
    end
end
puts("***************************************************")
sleep(5)

################################################################################
# Perform Simulate Link Up on port1 in System1-StaticLag-LHS                   #
################################################################################
puts("\n\nPerform Simulate Link Up on port1 in System1-StaticLag-LHS ")
@ixNet.execute('linkUpDn', vportTx1, 'up')
sleep(5)
################################################################################
# Retrieve protocol statistics                                                 #
################################################################################
puts("\nFetching all Protocol Summary Stats\n")
viewPage  = '::ixNet::OBJ-/statistics/view:"Protocols Summary"/page'
statcap   = @ixNet.getAttribute(viewPage, '-columnCaptions')
for statValList in @ixNet.getAttribute(viewPage, '-rowValues')
    for  statVal in statValList
        puts("***************************************************")
        index = 0
        for satIndv in statVal
            puts(statcap[index]+' '+satIndv)
            index = index + 1
        end
    end
end
puts("***************************************************")
puts("\nFetching all Static LAG Per Port Stats\n")
viewPage  = '::ixNet::OBJ-/statistics/view:"Static LAG Per Port"/page'
statcap   = @ixNet.getAttribute(viewPage, '-columnCaptions')
for statValList in @ixNet.getAttribute(viewPage, '-rowValues')
    for  statVal in statValList
        puts("***************************************************")
        index = 0
        for satIndv in statVal
            puts(statcap[index]+' '+satIndv)
            index = index + 1
        end
    end
end
puts("***************************************************")
################################################################################
# Retrieve StaticLag global Learned Info                                         #
################################################################################
puts("\n\n Retrieve StaticLag global Learned Info\n")
viewPageName = '::ixNet::OBJ-/statistics/view:"StaticLag-global-learned-Info-APIview"'
viewPage  = '::ixNet::OBJ-/statistics/view:"StaticLag-global-learned-Info-APIview"/page'

@ixNet.execute('refresh', viewPageName)
sleep(10)
statcap   = @ixNet.getAttribute(viewPage, '-columnCaptions')
for statValList in @ixNet.getAttribute(viewPage, '-rowValues')
    for  statVal in statValList
        puts("***************************************************")
        index = 0
        for satIndv in statVal
            puts(statcap[index]+' '+satIndv)
            index = index + 1
        end
    end
end
puts("***************************************************")
sleep(5)
################################################################################
# Stop all protocols                                                           #
################################################################################
puts('Stopping protocols')
@ixNet.execute('stopAllProtocols')

puts('!!! Test Script Ends !!!')
