import yaml
import sys
import subprocess

KUBECTL_LOCATION=subprocess.run(["/usr/bin/which", "kubectl"], capture_output=True, text=True).stdout.strip()

if len(sys.argv < 3):
	print("Run with name of VM to modify and host.")
	sys.exit(1)



vm=sys.argv[1]
gname=sys.argv[2]

GPU_STRING=subprocess.run([KUBECTL_LOCATION, "get", "pcidevice", gname,"-o",  "jsonpath='{.status.resourceName}'"], capture_output=True, text=True).stdout.strip().strip("'")



GPU_DEVICE=[{'deviceName':GPU_STRING, 'name':gname}]

orig_config_raw = subprocess.run([KUBECTL_LOCATION, "get", "vm", vm, "-o", "yaml"], capture_output=True, text=True).stdout.strip()
orig_config=yaml.safe_load(orig_config_raw)

orig_config["spec"]["template"]["spec"]["domain"]["devices"]["hostDevices"] = GPU_DEVICE

new_config_raw = yaml.dump(orig_config, sort_keys=False, allow_unicode=True)

with open("_temp.yaml", "w", encoding="utf-8") as f:
	f.write(new_config_raw)

subprocess.run([KUBECTL_LOCATION, "apply", "-f", "_temp.yaml"])
