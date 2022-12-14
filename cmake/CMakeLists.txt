foreach(FILE ccache configuration nltools package systemd)
    configure_file(${FILE}.cmake ${FILE}.cmake COPYONLY)
endforeach(FILE )
