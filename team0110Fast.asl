
 
 
+step(0) <- .println("START");?grid_size(A,B);+right(A);+down(B);+right;do(skip);do(skip);do(skip).


 +step(X): shoes(A,B)&pos(A,B)<-do(pick).


 +step(X): moves_per_round(6)<- !go;!go.

 +step(X):moves_per_round(3)<-!go.
 
 // do(right);do(right);do(right);do(left);do(left);do(left).
 
 //+!go<-do(skip);do(skip);do(skip).


 +!go: right & pos(A,B) & right(C)&A<C-1<- do(right);do(skip);do(skip).
 +!go: right <- -right;+left;do(up);do(left);do(left).	
 +!go: left & pos(A,B) & A>0 <- do(left);do(skip);do(skip).	
 +!go: left<-  -left;+right;do(up);do(right);do(right).


