void saluteUser(String userName, Float userLikelyhood){
  fill(255);
  String display = "";
  display += userName + ": " + userLikelyhood + "\n";
  text(display, 50, 60);
  
}
