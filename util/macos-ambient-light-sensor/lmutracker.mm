// lmutracker.mm
//
// https://stackoverflow.com/a/18614019/490829
//
// clang -o lmutracker lmutracker.mm -F /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks -framework Foundation -framework IOKit -framework CoreFoundation -framework BezelServices

#include <mach/mach.h>
#include <sys/event.h>
#include <sys/termios.h>
#import <Foundation/Foundation.h>
#include <unistd.h>
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

static bool stdout_isatty;

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
    printf(stdout_isatty ? "\e[2K\r%8lld %8lld" : "%8lld %8lld\n",
           values[0], values[1]);
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

  printf(stdout_isatty ? "\e[2K\r%8f" : "%8f\n", value);

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

int main(int argc, char* argv[]) {
  double value;
  kern_return_t kr;
  io_service_t serviceObject;
  CFRunLoopTimerRef updateTimer;

  stdout_isatty = isatty(STDOUT_FILENO);
  // dont buffer input or echo
  termios tattr, newtattr;
  if (tcgetattr(STDIN_FILENO, &tattr) == 0) {
    newtattr = tattr;
    newtattr.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newtattr);
  }
  int oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
  fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

  client = ALCALSCopyALSServiceClient();

  bool oneshot =
      argc < 2 || strcmp(argv[1], "--watch") != 0 && strcmp(argv[1], "-w") != 0;

                                                         if (client) {
    event = IOHIDServiceClientCopyEvent(client, kAmbientLightSensorEvent, 0, 0);

    if (event == NULL) {
      fprintf(stderr, "failed to get ambient light sensor event\n");
      exit(1);
    }

    value = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(kAmbientLightSensorEvent));

    CFRelease(event);

    setbuf(stdout, NULL);
    printf("%8f", value);

    if (oneshot) {
      printf("\n");
      exit(0);
    } else if (!stdout_isatty) {
      printf("\n");
    }

    updateTimer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                    CFAbsoluteTimeGetCurrent() + updateInterval, updateInterval,
                    0, 0, updateTimerCallBack, NULL);
  }
  else {
    fprintf(stderr, "falling back to legacy api\n");

    serviceObject = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleLMUController"));
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
    uint32_t outputs = 2;
    uint64_t values[outputs];
    kr = IOConnectCallMethod(dataPort, 0, nil, 0, nil, 0, values, &outputs, nil, 0);
    if (kr != KERN_SUCCESS) {
      mach_error("IOServiceOpen:", kr);
      exit(kr);
    }
    value = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(kAmbientLightSensorEvent));

    setbuf(stdout, NULL);
    printf("%8f", value);

    if (oneshot) {
      printf("\n");
      exit(0);
    } else if (!stdout_isatty) {
      printf("\n");
    }

    updateTimer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                    CFAbsoluteTimeGetCurrent() + updateInterval, updateInterval,
                    0, 0, updateTimerCallBackLegacy, NULL);
  }

  stdinRegister();
  CFRunLoopAddTimer(CFRunLoopGetCurrent(), updateTimer, kCFRunLoopDefaultMode);
  CFRunLoopRun();

  exit(0);
}
