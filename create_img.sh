EXE_NAME=ucos_bcm2835.elf
START_ADDR=0x00008000

arm-rtems5-objcopy -R -S --strip-debug -O binary "$EXE_NAME" "$EXE_NAME.bin" || exit 1
cat "$EXE_NAME.bin" | gzip -9 >"$EXE_NAME.gz"
mkimage \
  -A arm -O rtems -T kernel -a $START_ADDR -e $START_ADDR -n "RTEMS" \
  -d "$EXE_NAME.gz" "$EXE_NAME.img"

qemu-system-arm -M raspi2 \
  -serial stdio \
  -kernel "$EXE_NAME.img" -s -S
