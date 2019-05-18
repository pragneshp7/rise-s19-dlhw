Setting up for the Hardware Summer Project
==========================================

1. Getting access to Anmol's RISE Lab Machine
    - Install ZeroTier on your Machine - [ZeroTier](https://www.zerotier.com/download.shtml)
    
    - Enter this command in your command line. I will send you the network ID by email
    ```bash
        $ sudo zerotier-cli join <network-id>
    ```

    - Add this to your ```etc/hosts``` file
    ```bash
        10.147.17.206    rise_pc
    ```

    - Get SSH access to the machine. I will send you the username and password.
    ```bash
        $ ssh-copy-id <username>@rise_pc
        $ Enter your password
        $ ssh <username>@rise_pc
    ```

2. Setting up a Bluespec Hello-World
    - In this step, we will set-up a Hello World in Bluespec to ensure everything is okay
    
    - Clone this repo
    ```bash
        git clone https://github.com/anmolsahoo25/rise-s19-dlhw
        cd rise-s19-dlhw
    ```
    
    - Create a git branch first. Create a copy of the templates folder and rename it to <username> and run make.
    ```bash
        $ git checkout -b prereqs/hello-world-<username>
        $ cd prereqs/hardware
        $ cp hello-world/template hello-world/<username>
        $ cd hello-world/<username>
        $ make
    ```

    - This should print "Hello World". Edit TestModule.bsv and change the print message and re-run Make.

    - Now commit the changes and push
    ```bash
        $ git commit -am "hello-world done"
        $ git push origin prereqs/hello-world-<username>
    ```
