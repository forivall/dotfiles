xinput list | sed -En 's/.*DEXIN Corporation CM STORM SENTINEL GAMING MOUSE.*id=([0-9]+).*/\1/p'|xargs -n1 -i_ xinput --set-prop _ 'Device Accel Constant Deceleration' 1.8

xinput list | sed -En 's/.*Laview Technology Mionix Avior 7000.*id=([0-9]+).*pointer.*/\1/p'|xargs -n1 -i_ xinput --set-prop _ 'Device Accel Constant Deceleration' 2.2
