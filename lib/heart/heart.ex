defmodule LogstashJson.TCP.Heart do
    require Logger
    use GenServer
  
    def start_link(data, _opts \\ []) do
      GenServer.start_link(__MODULE__, data, name: __MODULE__)
    end
  
   
    def init(%{backend_name: backend_name}= data) do
        GenServer.cast(__MODULE__,{:init})
        {:ok, %{backend_name: backend_name, 
                heart_timer: nil
                }}
    end


    # Application.get_env(:logger, :logstash, [])
    # LogstashJson.TCP.Heart.get_cfg(:logstash)
    def get_cfg(backend_name) do 
        env = Application.get_env(:logger, backend_name, [])
        opts = Keyword.merge(env, [])
        workers = Keyword.get(opts, :workers) || 2
        heart_time = Keyword.get(opts, :heart_time) || 10_000
        heart_log_test = Keyword.get(opts, :heart_log_test) || false
        %{
            workers: workers,
            heart_time: heart_time,
            heart_log_test: heart_log_test
        }
    end

    # LogstashJson.TCP.Heart.update_cfg(:logstash,:heart_log_test,false)
    def update_cfg(backend_name, key,value) do 
        env = Application.get_env(:logger, backend_name, [])
        env= Keyword.put(env,key,value)
        Application.put_env(:logger,backend_name,env)
    end
  
  
    def handle_cast({:init},state) do 
        ##
        Logger.info(" heart init")
        cfg= get_cfg(state.backend_name)
        heart_timer= set_heart(cfg.heart_time)
        {:noreply,%{state| heart_timer: heart_timer}}
    end
  
    def handle_cast(_msg, state) do
      {:noreply, state}
    end
  
    def handle_call(_request, _from, state) do
        {:reply, :ok, state}
    end

    def handle_info({:timeout, timer, :heart_timer},state) do
        # :gen_tcp.send(sock, data)
        cfg= get_cfg(state.backend_name)
        if cfg.heart_log_test do 
            Logger.info(" heart timer")
        end
        do_heart(cfg.workers,cfg.heart_log_test)
        heart_timer= set_heart(cfg.heart_time)
        {:noreply,%{state| heart_timer: heart_timer}}
    end
  
    def handle_info(_msg, state) do 
        {:noreply, state}
    end
  
    def terminate(_reason, _state) do
      :ok
    end
  

    def set_heart(time_mills \\ 10_000) do 
        :erlang.start_timer(time_mills, self(), :heart_timer)
    end

    def do_heart(workers,heart_log_test) do 
        for i <- 1..workers do 
            LogstashJson.TCP.Connection.send_heart(i,heart_log_test)
        end
    end

  end
  