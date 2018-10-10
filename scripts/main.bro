module extDHCP;

export {
    ## known-dhcp-nets logging stream identifier
    redef enum Log::ID += { DHCP_NETS_LOG };

    ## The record type that contains the column fields for known-dhcp-nets log
    type DHCPNetInfo: record {
        ## The timestamp when this network was observed
        ts:     time &log;
        ## The network that was detected as being assigned by a DHCP server
        net:    subnet &log;
    };

    ## Holds the set of all known dhcp networks.
    global dhcp_net_store: Cluster::StoreInfo;

    ## The broker topic name to use to store known dhcp networks.
    const dhcp_net_store_name = "bro/known/dhcp_nets" &redef;

    ## The expiry interval for new entries
    const dhcp_net_store_expiry = 1day &redef;

    ## The timeout interval for operations on the store.
    option dhcp_net_store_timeout = 15sec;

    ## An event that can be handled to access the DHCPNetInfo record
    ## as it is sent to the logging framework.
    global log_known_dhcp_nets: event(rec: DHCPNetInfo);
}

event bro_init()
    {
    Log::create_stream(extDHCP::DHCP_NETS_LOG, [$columns=DHCPNetInfo, $ev=log_known_dhcp_nets, $path="known_dhcp_nets"]);
    extDHCP::dhcp_net_store = Cluster::create_store(extDHCP::dhcp_net_store_name);
    }

event extDHCP::dhcp_subnet_seen(s: subnet)
    {
    local info = DHCPNetInfo($ts = network_time(), $net = s);
    when ( local r = Broker::put_unique(extDHCP::dhcp_net_store$store, info$net, 
                                            T, extDHCP::dhcp_net_store_expiry))
        {
        if ( r$status == Broker::SUCCESS )
            {
            if ( r$result as bool )
                Log::write(extDHCP::DHCP_NETS_LOG, info);
            }
        else
            Reporter::error(fmt("%s: data store put_unique failure",
                                extDHCP::dhcp_net_store_name));
        }
    timeout extDHCP::dhcp_net_store_timeout
        {
        Reporter::error(fmt("%s: data store put_unique timeout",
                                extDHCP::dhcp_net_store_name));
        # can't tell if master store inserted the key or not
        Log::write(extDHCP::DHCP_NETS_LOG, info);
        }
    }
