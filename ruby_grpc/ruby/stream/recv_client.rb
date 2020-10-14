this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(File.dirname(this_dir), 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_stream_services_pb'

def main
  count = ARGV.size > 0 ?  ARGV[0].to_i : 10
  hostname = ARGV.size > 1 ?  ARGV[1] : 'localhost:50051'
  stub = Msg::Frame::Stub.new(hostname, :this_channel_is_insecure)

    length = 1
    command = 2
    dest = 3
    msgid = count

    senddata = stub.send_msg(Msg::IdData.new(length: length,
                                          command: command,
                                          dest: dest,
                                          msgid: msgid))
    senddata.each do |s|
      p "#{s}"
    end

    response = stub.time_result(Msg::IdData.new(length: length,
                                          command: command,
                                          dest: dest,
                                          msgid: msgid))
end

main

