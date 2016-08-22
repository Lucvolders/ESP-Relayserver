wifi.setmode(wifi.STATION)
--wifi.sta.config("MYROUTERNAME","PASSWORD")
wifi.sta.config("ZyXEL9680AC","B9BB53BCA049")
print(wifi.sta.getip())
relay = 3
relaystate = 0
switch1 = 2
manual =1
led = 4
gpio.mode(led, gpio.OUTPUT)
gpio.write(led,gpio.LOW);
gpio.mode(relay, gpio.OUTPUT)
gpio.write(relay, gpio.HIGH);
relaystate=0
gpio.mode(switch1, gpio.INPUT, gpio.PULLUP);
gpio.mode(manual, gpio.INPUT, gpio.PULLUP);
srv=net.createServer(net.TCP)

tmr.alarm(1, 1000, 1, function()
if (gpio.read(manual) == 0) then
    gpio.write(led,gpio.HIGH);
    print (gpio.read(switch1))
    if (gpio.read(switch1) == 0) then
    gpio.write(relay,gpio.LOW);
    relaystate=1
    elseif (gpio.read(switch1) == 1) then
    gpio.write(relay,gpio.HIGH);
    relaystate=0
    end
end
if (gpio.read(manual) == 1) then
gpio.write(led,gpio.LOW);
end
end)



srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf..'<head><meta http-equiv="refresh" content="20" /></head>'
        buf = buf.."<h1> ESP8266 Relay Switch</h1>";
        buf = buf.."<h1> Luc Volders 2016</h1>";
        if (gpio.read(manual) == 0) then
            buf = buf.."<br/>";
            buf = buf.."Manual override = ON"
            buf = buf.."<br/><br/>";
        elseif (gpio.read(manual) == 1) then
            buf = buf.."<br/>";
            buf = buf.."Manual override = OFF"
            buf = buf.."<br/><br/>";
        end
            if (gpio.read(switch1) == 0) then
                buf = buf.."Manual Switch = ON";
            elseif (gpio.read(switch1) == 1) then
                buf = buf.."Manual Switch = OFF";
            end
            buf = buf.."<br/>";
            if (relaystate == 1) then
                buf = buf.."Relay is ON";
            elseif (relaystate == 0) then   
                buf = buf.."Relay is OFF";
            end 
            buf = buf.."<br/><br/>";    
        --end
        buf = buf.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
        local _on,_off = "",""
        if (gpio.read(manual) == 1) then
            if(_GET.pin == "ON1")then
                gpio.write(relay, gpio.LOW);
                relaystate=1
            elseif(_GET.pin == "OFF1")then
                gpio.write(relay, gpio.HIGH); 
                relaystate=0    
            end
        end    
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
