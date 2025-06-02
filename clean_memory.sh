#!/bin/bash
# Save as ~/clean_memory.sh
echo 3 | sudo tee /proc/sys/vm/drop_caches
sudo sync