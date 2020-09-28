#!/usr/bin/env ruby

# Copyright 2015 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Sample gRPC server that implements the Greeter::Helloworld service.
#
# Usage: $ path/to/greeter_server.rb

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_services_pb'

$array = []
$ID = []

# GreeterServer is simple server that implements the Helloworld Greeter server.
class MsgServer < Msg::Frame::Service
  # say_hello implements the SayHello rpc method.
  def send_msg(iddata, _unused_call)
    senddata = $array.shift
    puts "#{$array}\n"

    
    Msg::SendData.new(length: senddata.length,
                      command: senddata.command,
                      dest: senddata.dest,
                      msgid: iddata.msgid,
                      message: senddata.message)
  end
  
  def recv_msg(recvdata, _unused_call)
    $array.push recvdata
    puts "#{$array}\n"
    
    Msg::Response.new(length: recvdata.length,
                      command: recvdata.command,
                      dest: recvdata.dest,
                      msgid: 0,
                      rescode: $array.length)
  end

  def recv_id(iddata, _unused_call)
    $ID.push iddata.msgid

    Msg::Response.new(length: iddata.length,
                      command: iddata.command,
                      dest: iddata.dest,
                      msgid: 0,
                      rescode: $array.length)
  end
end

# main starts an RpcServer that receives requests to GreeterServer at the sample
# server port.
def main
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(MsgServer)
  # Runs the server with SIGHUP, SIGINT and SIGQUIT signal handlers to 
  #   gracefully shutdown.
  # User could also choose to run server via call to run_till_terminated
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

main
