/* -*- P4_16 -*- */

// CS5229 Programming Assignment 2
// Part A - 2 Secret Message
//
// Name: Albert Einstein
// Student Number: A0123456B
// NetID: e0123456

#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
const bit<16> TYPE_SECRET = 0xFFFF;
const bit<32> SWITCH_IP = 0x0a0000FE;

enum bit<16> SECRET_OPT {
    DROPOFF = 0x0001,
    PICKUP  = 0x0002,
    SUCCESS = 0xFFFF,
    FAILURE = 0x0000,
    WRONGPW = 0x2333
}

const bit<8>  IPV4_UDP_PRON = 0x11;
const bit<32> OV_VAL = 0xdeadbeef;
const bit<32> MAX_HASHED_VAL = 0xFFFFFFFF;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header icmp_t {
    /* TODO: your code here */
    /* Hint: define ICMP header */
}

header udp_t {
    /* TODO: your code here */
    /* Hint: define UDP header */
}

header secret_t {
    bit<32> hostID;
    bit<32> salt;
    bit<32> pw_hash;
    bit<16> opCode;
    bit<16> mailboxNum;
    bit<32> message;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    udp_t        udp;
    secret_t     secret;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        /* TODO: your code here */
        /* Hint: implement your parser */
        transition accept;
    }

}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    
    register<bit<32>>(65536) secret_mailboxes;
    register<bit<32>>(65536) msg_checksums;

    action drop() {
        mark_to_drop(standard_metadata);
    }

    action ipv4_forward_action(egressSpec_t port) {
        standard_metadata.egress_spec = port;
    }

    action check_password(bit<32> stored_password) {
        /* TODO: your code here */
    }

    table ipv4_forward {
        key = {
            hdr.ipv4.dstAddr: exact;
        }
        actions = {
            ipv4_forward_action;
            drop;
        }
        default_action = drop();
    }

    table password_check {
        key = {
            hdr.secret.hostID: exact;
        }
        actions = {
            check_password;
            drop;
        }
        default_action = drop();
    }

    apply {
        if(hdr.secret.isValid()) {
            /* TODO: your code here */
            /* Hint 1: verify if the secret message is destined to the switch */

            /* Hint 2: check password before processing the packet */

            /* Hint 3: if the password is correct, continue; if the password is incorrect, what should you reply? */

            /* Hint 4: there are two cases to handle -- DROPOFF, PICKUP */

            /* Hint 5: what happens when you PICKUP from an empty mailbox? */

            /* Hint 6: remember to "sanitize" your mailbox with 0xdeadbeef after every PICKUP */

            /* Hint 7: msg_checksums are important! */

            /* Hint 8: once everything is done, swap addresses, set port and reply to sender */
        }
        ipv4_forward.apply();
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply {
        update_checksum(
            hdr.ipv4.isValid(),
            { 
                hdr.ipv4.version,
                hdr.ipv4.ihl,
                hdr.ipv4.diffserv,
                hdr.ipv4.totalLen,
                hdr.ipv4.identification,
                hdr.ipv4.flags,
                hdr.ipv4.fragOffset,
                hdr.ipv4.ttl,
                hdr.ipv4.protocol,
                hdr.ipv4.srcAddr,
                hdr.ipv4.dstAddr 
            },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16
        );
    }
}


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        /* TODO: your code here */
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
