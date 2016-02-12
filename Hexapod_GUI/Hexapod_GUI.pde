import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.widget.Toast;
import android.view.Gravity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;

import java.util.UUID;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import android.util.Log;

import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;

BluetoothAdapter bt = BluetoothAdapter.getDefaultAdapter();
BroadcastReceiver myDiscoverer = new myOwnBroadcastReceiver();

color background, buttons, text, pressed;
color spdu, spdd, stp, up, lft, rgt, dwn, rlt, rrt;

void setup()
{ 
  orientation(PORTRAIT);
  rectMode(CORNER);
  textAlign(CENTER, CENTER);
  textSize(30);

  background = color(44, 62, 80);
  buttons = color(149, 165, 166);
  text = color(0, 0, 0);
  pressed = color(41, 128, 85);

  spdu = buttons;
  spdd = buttons;
  stp = buttons;
  up = buttons;
  lft = buttons;
  rgt = buttons;
  dwn = buttons;
  dwn = buttons;
  rlt = buttons;
  rrt = buttons;

  if (bt.isEnabled()) 
  {
    registerReceiver(myDiscoverer, new IntentFilter(BluetoothDevice.ACTION_FOUND));
    if (!bt.isDiscovering()) {
      bt.startDiscovery();
    }
  }

}

void draw()
{
  if (bt.isEnabled())
    background(background);
  else
    background(text);  
  mousePos();
  update();

  fill(spdu);
  rect(0, 0, 75*2.4, 75*2.28);
  fill(text);
  text("Speed Up", 0, 0, 75*2.4, 75*2.28);

  fill(spdd);
  rect(225*2.4, 0, 75*2.4, 75*2.28);
  fill(text);
  text("Slow Down", 225*2.4, 0, 75*2.4, 75*2.28);

  fill(rlt);
  rect(0, 450*2.28, 145*2.4, 75*2.28);
  fill(text);
  text("Rotate Left", 0, 450*2.28, 150*2.4, 75*2.28);

  fill(rrt);
  rect(155*2.4, 450*2.28, 155*2.4, 75*2.28);
  fill(text);
  text("Rotate Right", 155*2.4, 450*2.28, 150*2.4, 75*2.28);

  drawArrows();

  fill(stp);
  ellipse(150*2.4, 263*2.28, 100*2.4, 50*2.28);
  fill(text);
  text("Stop", 100*2.4, 235*2.28, 100*2.4, 50*2.28);
}

void drawArrows()
{
  fill(rgt);
  triangle(210*2.4, 235*2.28, 210*2.4, 292*2.28, 250*2.4, 262*2.28);//up
  fill(lft);
  triangle(90*2.4, 235*2.28, 90*2.4, 292*2.28, 50*2.4, 262*2.28);
  fill(up);
  triangle(210*2.4, 235*2.28, 90*2.4, 235*2.28, 150*2.4, 197*2.28);//dwn
  fill(dwn);
  triangle(210*2.4, 292*2.28, 90*2.4, 292*2.28, 150*2.4, 330*2.28);
}

void mousePos()
{
  fill(255, 0, 0);
  text("(" + mouseX + "," + mouseY +")", 150*2.5, 10*2.28);
}

void update()
{
  if (mousePressed)
  {
    if (mouseX >= 218 && mouseX <= 503 &&
      mouseY >= 450 && mouseY <= 536)
    {
      up = pressed;
      sendDataToPairedDevice("u", bt.getRemoteDevice("20:13:09:29:10:28"));
    }
    else if (mouseX >= 123 && mouseX <= 218 &&
      mouseY >= 536 && mouseY <= 664)
    {
      lft = pressed;
      sendDataToPairedDevice("l", bt.getRemoteDevice("20:13:09:29:10:28"));
    }
    else if (mouseX >= 218 && mouseX <= 503 &&
      mouseY >= 664 && mouseY <= 753)
    {
      dwn = pressed;
      sendDataToPairedDevice("d", bt.getRemoteDevice("20:13:09:29:10:28"));
    }
    else if (mouseX >= 503 && mouseX <= 596 && 
      mouseY >= 535 && mouseY <= 664)
    {
      rgt = pressed;
      sendDataToPairedDevice("r", bt.getRemoteDevice("20:13:09:29:10:28"));
    }
    else if (mouseX >= 240 && mouseX <= 480 &&
      mouseY >= 555 && mouseY <= 655)
    {
      stp = pressed;
      sendDataToPairedDevice("s", bt.getRemoteDevice("20:13:09:29:10:28"));
    }
    else if (mouseX >= 0 && mouseX <= 180 &&
      mouseY >= 0 && mouseY <= 175)
    {
      spdu = pressed;
      sendDataToPairedDevice("p", bt.getRemoteDevice("20:13:09:29:10:28"));
    }
    else if (mouseX >= 540 && mouseX <= 720 &&
      mouseY >= 0 && mouseY <= 175)
    {
      spdd = pressed;
      sendDataToPairedDevice("o", bt.getRemoteDevice("20:13:09:29:10:28"));
    }
    else if (mouseX >= 0 && mouseX <= 345 &&
      mouseY >= 1025&& mouseY <= 1180)
    {
      rlt = pressed;
      sendDataToPairedDevice("q", bt.getRemoteDevice("20:13:09:29:10:28"));
    }
    else if (mouseX >= 375 && mouseX <= 720 &&
      mouseY >= 1025 && mouseY <= 1180)
    {
      rrt = pressed;
      sendDataToPairedDevice("w", bt.getRemoteDevice("20:13:09:29:10:28"));
    }
  }
}

void mouseReleased()
{
  spdu = buttons;
  spdd = buttons;
  stp = buttons;
  up = buttons;
  lft = buttons;
  rgt = buttons;
  dwn = buttons;
  dwn = buttons;
  rlt = buttons;
  rrt = buttons;
}

/* My ToastMaster function to display a messageBox on the screen */
void ToastMaster(String textToDisplay) {
  Toast myMessage = Toast.makeText(getApplicationContext(), 
  textToDisplay, 
  Toast.LENGTH_LONG);
  myMessage.setGravity(Gravity.CENTER, 0, -350);
  myMessage.show();
}

/* This BroadcastReceiver will display discovered Bluetooth devices */
public class myOwnBroadcastReceiver extends BroadcastReceiver {
 @Override
 public void onReceive(Context context, Intent intent) {
 String action=intent.getAction();
 ToastMaster("ACTION:" + action);
 
 //Notification that BluetoothDevice is FOUND
 if(BluetoothDevice.ACTION_FOUND.equals(action)){
 //Display the name of the discovered device
 String discoveredDeviceName = intent.getStringExtra(BluetoothDevice.EXTRA_NAME);
 ToastMaster("Discovered: " + discoveredDeviceName);
 
 //Display more information about the discovered device
 BluetoothDevice discoveredDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
 ToastMaster("getAddress() = " + discoveredDevice.getAddress());
 ToastMaster("getName() = " + discoveredDevice.getName());
 
 int bondyState=discoveredDevice.getBondState();
 ToastMaster("getBondState() = " + bondyState);
 
 String mybondState;
 switch(bondyState){
 case 10: mybondState="BOND_NONE";
 break;
 case 11: mybondState="BOND_BONDING";
 break;
 case 12: mybondState="BOND_BONDED";
 break;
 default: mybondState="INVALID BOND STATE";
 break;
 }
 ToastMaster("getBondState() = " + mybondState);
 }
 }
} 

private void sendDataToPairedDevice(String message, BluetoothDevice device)
{       
  byte[] toSend = message.getBytes();
  try {
    UUID applicationUUID = UUID.fromString("8ce255c0-200a-11e0-ac64-0800200c9a66");
    BluetoothSocket socket = device.createInsecureRfcommSocketToServiceRecord(applicationUUID);
    OutputStream mmOutStream = socket.getOutputStream();
    mmOutStream.write(toSend);
    // Your Data is sent to  BT connected paired device ENJOY.
  } 
  catch (IOException e) {
    Log.e("", "Exception during write", e);
  }
}

