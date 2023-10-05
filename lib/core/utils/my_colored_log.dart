void myLogColored(String where, String message, bool isError) {
  print(
      "\n\x1B[35m========-----------------------------------------------------========\x1B[0m\n");
  if (isError) {
    print("\x1B[31m${where.toUpperCase()}:\x1B[0m");
    print("\x1B[31m$message\x1B[0m");
  } else {
    print("\x1B[33m${where.toUpperCase()}:\x1B[0m");
    print("\x1B[33m$message\x1B[0m");
  }
  print(
      "\n\x1B[35m========-----------------------------------------------------========\x1B[0m\n");
}
