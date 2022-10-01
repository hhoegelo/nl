foreach(FILE package systemd nltools)
    configure_file(${FILE}.cmake ${FILE}.cmake COPYONLY)    
endforeach(FILE )
