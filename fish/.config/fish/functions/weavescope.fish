function weavescope --description 'Inicia o Weave Scope corrigido'
    if not docker info >/dev/null 2>&1
        echo (set_color red)"Erro: O Docker não está rodando."(set_color normal)
        return 1
    end

    # Limpeza total
    docker rm -f weavescope >/dev/null 2>&1

    # Comando otimizado
    docker run -d --name=weavescope \
      --privileged \
      --pid=host \
      --net=host \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /sys/kernel/debug:/sys/kernel/debug \
      weaveworks/scope:1.13.2 \
      --probe.docker=true \
      --weave=false

    echo (set_color blue)"Aguarde 10 segundos e acesse:"(set_color normal) (set_color --bold green)"http://localhost:4040"(set_color normal)
end
