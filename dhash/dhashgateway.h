
// Forward declarations.
class asrv;
class svccb;

class chord;
#include <route.h>
#include <paxos_prot.h> 

class dhashcli;
class dhash_block;

class dhashgateway : public virtual refcount
{
  ptr<asrv> clntsrv;
  ptr<dhashcli> dhcli; 
  ptr<vnode> vn; 

  void dispatch (svccb *sbp);
  void insert_cb (svccb *sbp, dhash_stat status, vec<chordID> path);
  void retrieve_cb (svccb *sbp, dhash_stat status, ptr<dhash_block> block,
                    route path);

  void ndlist_cb(svccb * sbp, dhash_stat stat, ptr<dhash_block> block, route path);
  void send_paxos_prepare(paxos_prep_arg* arg, svccb * sdp);
  void send_paxos_accept(paxos_accept_arg* arg, svccb * sdp);
  void handle_acc_tmo(svccb * sdp); 
  void handle_tmo(svccb * sdp); 
  void handle_prepare(svccb * sdp, paxos_prepres* result, clnt_stat s); 
  void handle_accept(svccb * sdp, paxos_accept_res * result, clnt_stat s); 
  
public:
  dhashgateway (ptr<axprt_stream> x, ptr<chord> clnt, ref<dhash> dh);
  ~dhashgateway ();
};
