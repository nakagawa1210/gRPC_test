this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_bro_services_pb'

def main()
  count = ARGV.size > 0 ?  ARGV[0].to_i : 10
  hostname = ARGV.size > 1 ?  ARGV[1] : 'localhost:50051'
  stub = Msg::Frame::Stub.new(hostname, :this_channel_is_insecure)

  (1..count).each{|num|
    sleep(0.001)
    message = num.to_s
    length = num
    dest = num
    command = num
    begin
      response = stub.recv_msg(Msg::RecvData.new(length: length,
                                                 command: command,
                                                 dest: dest,
                                                 message: message))
      #puts "#{response}\n"
    rescue GRPC::BadStatus => e
      abort "ERROR: #{e.message}"
    end
  }
end

main
