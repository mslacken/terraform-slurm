#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=00:05:00
sleep=${1:-30}
echo "$(date): start on $(uname -n)"
echo "sleep for $sleep"
sleep $sleep
echo "$(date): end on $(uname -n)"
