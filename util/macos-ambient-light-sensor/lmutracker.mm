// lmutracker.mm
//
// https://stackoverflow.com/a/18614019/490829
//
// clang -o lmutracker lmutracker.mm -framework IOKit -framework CoreFoundation

#include <mach/mach.h>
#include <sys/event.h>
#include <sys/termios.h>
#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/hidsystem/IOHIDServiceClient.h>

typedef struct __IOHIDEvent *IOHIDEventRef;

#define kAmbientLightSensorEvent 12

#define IOHIDEventFieldBase(type) (type << 16)

extern "C" {
  IOHIDEventRef IOHIDServiceClientCopyEvent(IOHIDServiceClientRef, int64_t, int32_t, int64_t);
  double IOHIDEventGetFloatValue(IOHIDEventRef, int32_t);

  // BezelServices.framework
  IOHIDServiceClientRef ALCALSCopyALSServiceClient(void);
}

static char stdinbuf[1];

static CFStringRef kbdEventMode = CFSTR("com.forivall.lmutracker.kbd");

static double updateInterval = 0.1;
static io_connect_t dataPort = 0;

static IOHIDServiceClientRef client;
static IOHIDEventRef event;

void updateTimerCallBackLegacy(CFRunLoopTimerRef timer, void *info) {
  kern_return_t kr;
  uint32_t outputs = 2;
  uint64_t values[outputs];

  kr = IOConnectCallMethod(dataPort, 0, nil, 0, nil, 0, values, &outputs, nil, 0);
  if (kr == KERN_SUCCESS) {
    printf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%8lld %8lld", values[0], values[1]);
    return;
  }

  if (kr == kIOReturnBusy) {
    return;
  }

  mach_error("I/O Kit error:", kr);
  exit(kr);
}

void updateTimerCallBack(CFRunLoopTimerRef timer, void *info) {
  double value;

  event = IOHIDServiceClientCopyEvent(client, kAmbientLightSensorEvent, 0, 0);

  value = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(kAmbientLightSensorEvent));

  printf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%8f", value);

  CFRelease(event);
}

void stdinRegister();
void stdinCallBack(CFFileDescriptorRef fd, CFOptionFlags flags, void* info) {
  NSFileHandle *fileH = NSFileHandle.fileHandleWithStandardInput;
  NSString *str = [[NSString alloc] initWithData:fileH.availableData encoding:NSUTF8StringEncoding];
  if ([str hasPrefix:@"q"]) {
    printf("\n");
    exit(0);
  }
  stdinRegister();
}
void stdinRegister() {
  CFFileDescriptorRef fd = CFFileDescriptorCreate(kCFAllocatorDefault, STDIN_FILENO, false, stdinCallBack, NULL);
  CFFileDescriptorNativeDescriptor nfd = CFFileDescriptorGetNativeDescriptor(fd);
  CFFileDescriptorEnableCallBacks(fd, kCFFileDescriptorReadCallBack);
  CFRunLoopSourceRef source = CFFileDescriptorCreateRunLoopSource(kCFAllocatorDefault, fd, 0);
  CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
}

int main(void) {
  kern_return_t kr;
  io_service_t serviceObject;
  CFRunLoopTimerRef updateTimer;

  // dont buffer input
  termios tattr, newtattr;
  if (tcgetattr(STDIN_FILENO, &tattr) == 0) {
    newtattr = tattr;
    newtattr.c_lflag &= ~(ICANON /* | ECHO */);
    tcsetattr(STDIN_FILENO, TCSANOW, &newtattr);
  }
  int oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
  fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

  client = ALCALSCopyALSServiceClient();

  if (client) {
    event = IOHIDServiceClientCopyEvent(client, kAmbientLightSensorEvent, 0, 0);

    if (event == NULL) {
      fprintf(stderr, "failed to get ambient light sensor event\n");
      exit(1);
    }
    CFRelease(event);

    setbuf(stdout, NULL);
    printf("%8f", 0.0);

    updateTimer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                    CFAbsoluteTimeGetCurrent() + updateInterval, updateInterval,
                    0, 0, updateTimerCallBack, NULL);
  } else {
    fprintf(stderr, "falling back to legacy api\n");

    serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleLMUController"));
    if (!serviceObject) {
      fprintf(stderr, "failed to find ambient light sensors\n");
      exit(1);
    }

    kr = IOServiceOpen(serviceObject, mach_task_self(), 0, &dataPort);
    IOObjectRelease(serviceObject);
    if (kr != KERN_SUCCESS) {
      mach_error("IOServiceOpen:", kr);
      exit(kr);
    }

    setbuf(stdout, NULL);
    printf("%8ld %8ld", 0L, 0L);

    updateTimer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                    CFAbsoluteTimeGetCurrent() + updateInterval, updateInterval,
                    0, 0, updateTimerCallBackLegacy, NULL);
  }


  stdinRegister();
  CFRunLoopAddTimer(CFRunLoopGetCurrent(), updateTimer, kCFRunLoopDefaultMode);
  CFRunLoopRun();

  exit(0);
}
