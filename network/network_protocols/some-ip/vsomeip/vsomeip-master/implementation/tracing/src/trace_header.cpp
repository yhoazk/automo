// Copyright (C) 2016-2017 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#include <cstring>

#include "../include/trace_header.hpp"
#include "../../endpoints/include/endpoint.hpp"
#include "../../endpoints/include/client_endpoint.hpp"
#include "../../utility/include/byteorder.hpp"

namespace vsomeip {
namespace tc {

bool trace_header::prepare(const std::shared_ptr<endpoint> &_endpoint,
        bool _is_sending, instance_t _instance) {
    return prepare(_endpoint.get(), _is_sending, _instance);
}

bool trace_header::prepare(const endpoint *_endpoint, bool _is_sending,
        instance_t _instance) {
    boost::asio::ip::address its_address;
    unsigned short its_port(0);
    protocol_e its_protocol(protocol_e::unknown);

    if (_endpoint) {
        const client_endpoint* its_client_endpoint =
                dynamic_cast<const client_endpoint*>(_endpoint);
        if (its_client_endpoint) {

            its_client_endpoint->get_remote_address(its_address);
            if (its_address.is_v6()) {
                return false;
            }

            its_port = its_client_endpoint->get_remote_port();

            if (_endpoint->is_local()) {
                its_protocol = protocol_e::local;
            } else {
                if (_endpoint->is_reliable()) {
                    its_protocol = protocol_e::tcp;
                } else {
                    its_protocol = protocol_e::udp;
                }
            }
        }
    }
    prepare(its_address.to_v4(), its_port, its_protocol, _is_sending, _instance);
    return true;
}

void trace_header::prepare(const boost::asio::ip::address_v4 &_address,
                           std::uint16_t _port, protocol_e _protocol,
                           bool _is_sending, instance_t _instance) {
    unsigned long its_address_as_long = _address.to_ulong();
    data_[0] = VSOMEIP_LONG_BYTE3(its_address_as_long);
    data_[1] = VSOMEIP_LONG_BYTE2(its_address_as_long);
    data_[2] = VSOMEIP_LONG_BYTE1(its_address_as_long);
    data_[3] = VSOMEIP_LONG_BYTE0(its_address_as_long);
    data_[4] = VSOMEIP_WORD_BYTE1(_port);
    data_[5] = VSOMEIP_WORD_BYTE0(_port);
    data_[6] = static_cast<byte_t>(_protocol);
    data_[7] = static_cast<byte_t>(_is_sending);
    data_[8] = VSOMEIP_WORD_BYTE1(_instance);
    data_[9] = VSOMEIP_WORD_BYTE0(_instance);
}

} // namespace tc
} // namespace vsomeip
