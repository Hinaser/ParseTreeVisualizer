constructTreeView = function(cst, $){
  if(!$.fn || !$.fn.jquery){
    throw "jQuery is not loaded or jQuery object is invalid.";
  }
  
  var treeView = $("<ul class='treeView'>");
  var treeRoot = $("<li>");
  treeView.append(treeRoot);
  
  var stack = [];
  stack.push([treeRoot]);
  
  var isRootRule = true;
  
  cst.treeView = treeView;
  cst.treeViewRoot = ".treeView > li > ul";
  
  return function (t){
    var currentStack = stack.length;
    var parent = stack[currentStack - 1][0];
    
    if(isRootRule){
      treeRoot.text(CST.ruleNames(t.r));
      isRootRule = false;
    }
    
    stack[currentStack] = [];
    
    var tree = $("<ul class='parent'>");
    for(var i=0; i < t.c.length; i++){
      var node = null;
      
      if(t.c[i].hasOwnProperty("r")){
        node = $("<li class='rule'>");
        node.text(CST.ruleNames(t.c[i].r));
        stack[currentStack].push(node);
      }
      else if(t.c[i].hasOwnProperty("t")){
        node = $("<li class='leaf'>");
        if(t.c[i].l != -1){
            node.append($("<span class='leaf-text'>").text(t.c[i].t));
            node.append($("<span class='token-name'>").text(CST.tokenNames(t.c[i].l)));
        }
        else{
            node.append($("<span class='leaf-text'>").text(""));
            node.append($("<span class='token-name'>").text("EOF"));
        }
      }
      
      tree.append(node);
    }
    
    parent.append(tree);
    
    if(stack[currentStack].length < 1){
      stack.splice(currentStack, 1);
    }
    if(currentStack > 0){
      stack[currentStack - 1].shift();
      if(stack[currentStack - 1].length < 1){
        stack.splice(currentStack - 1, 1);
      }
    }
  }
};
