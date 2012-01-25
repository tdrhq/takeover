require "takeover/version"
require 'timeout'
require 'socket'

module Takeover
  # Your code goes here...
  class Stuff
    def initialize(port)
      @port = port
    end

    # kill the process currently owning the given port
    def kill_current(port = mapping, sig = "INT")
      if port
        system("fuser -n tcp  -k -#{sig} #{port}/tcp")
      end
    end

    # get the current mapping for the given port 
    def mapping
      e = chains = `sudo iptables -L PREROUTING -t nat`.split("\n").select { |i|
        i =~ /dpt:#{@port}/
      }

      return nil if e == [] 
      e.first.split.last.to_i
    end

    def set_mapping(to_port)
      system("sudo iptables -t nat -A PREROUTING -p tcp --dport #{@port} -j REDIRECT --to-port #{to_port}")
    end

    def del_mapping(to_port)
      system("sudo iptables -t nat -D PREROUTING -p tcp --dport #{@port} -j REDIRECT --to-port #{to_port}")
    end

    def set_mapping_and_interrupt(to_port)
      current = mapping
      kill_current(current, "INT")
      set_mapping(to_port)
      del_mapping(current)
    end

    def is_port_open?(port)
      begin
        Timeout::timeout(1) do
          begin
            TCPSocket.new("127.0.0.1", port).close
            puts "socket is open!"
            return true
          rescue  Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue Timeout::Error
        return false
      end
    end

    def map_when_available_sync(to_port, timeout = 2 * 60)
      # wait for the port to 
      
      end_time = Time.now + timeout
      while (Time.now < end_time) 
        if (is_port_open?(to_port))
          set_mapping(to_port)
          return
        else
          puts "port not yet open"
        end
      end
      
      raise "server did not come up even after #{timeout.to_i} seconds"
    end

    def map_when_available(to_port, timeout = 2 * 60)
      p1 = fork {
        map_when_available_sync(to_port, timeout)
      }
      Process.detach(p1)
    end
  end

  def self.for(port)
    Stuff.new(port)
  end

  # a convenience call for the service to decide what port to run on.
  def self.free_port
    s = TCPServer.new 0
    ret = s.addr[1]
    s.close
    ret
  end
end
