# Log DHCP Nets

This module attempts to enumerate all DHCP networks in use on a network through observation. The module should require no additional configuration and is ready for use out of the box.

### New Types

#### DHCPNetInfo

**ts**: The timestamp when this was observed.
**net**: The network observed being assigned by the DHCP server.

### Events Generated

#### log_known_dhcp_nets(rec: extDHCP::DHCPNetInfo)

This event creates an opportunity for a user to access the DHCP network being logged as it is sent to the logging framework.

### Example of Log Generated

```
#separator \x09
#set_separator	,
#empty_field	(empty)
#unset_field	-
#path	known_dhcp_nets
#open	2018-10-10-15-00-04
#fields	ts	net
#types	time	subnet
1539183604.842641	10.2.3.0/21
1539183614.179737	10.4.5.0/21
1539183640.513793	10.7.8.0/21
1539183721.439599	10.50.204.0/23
1539183771.072645	10.31.1.0/21
1539183892.691220	10.77.44.0/21
1539183906.950220	10.22.21.0/21
1539183944.464731	10.80.4.0/21
1539184017.082912	10.50.221.0/24
1539184047.567839	10.254.77.0/24
```
