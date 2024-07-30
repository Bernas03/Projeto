package com.example.andoid_studio;

/*import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
}


package com.example.your_app; // Altere para o pacote do seu aplicativo*/

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothSocket;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.io.IOException;
import java.util.Set;
import java.util.UUID;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev/bluetooth";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getPairedDevices")) {
                                Set<BluetoothDevice> pairedDevices = getPairedDevices();
                                result.success(pairedDevicesToString(pairedDevices));
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private Set<BluetoothDevice> getPairedDevices() {
        BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(BLUETOOTH_SERVICE);
        BluetoothAdapter bluetoothAdapter = bluetoothManager.getAdapter();
        return bluetoothAdapter.getBondedDevices();
    }

    private String pairedDevicesToString(Set<BluetoothDevice> devices) {
        StringBuilder sb = new StringBuilder();
        for (BluetoothDevice device : devices) {
            sb.append(device.getName()).append(" - ").append(device.getAddress()).append("\n");
        }
        return sb.toString();
    }
}
