# packer_qemu_openindiana
Create OpenIndiana images for KVM/qemu with HashiCorp Packer

Replace id_rsa.pub with your public SSH key, then build...
```
packer build main.pkr.hcl
```

...and start the image with qemu...
```
qemu-kvm -hdc artifacts/packer-openindiana -m 2048 -net nic -net user,hostfwd=tcp::2222-:22 -display none
```
...and connect with SSH:
```
ssh openindiana@localhost -p 2222 -i id_rsa
```

