-- -*- lua -*-
whatis("Samtools is a suite of programs for interacting with high-throughput sequencing data")

prepend_path("PATH", "/usr/local/samtools-1.6/bin")


--[[
Build:
    # unzip
    # ./configure ./configure --prefix=/usr/local/samtools-1.6 --without-curses
    # make install
--]]

