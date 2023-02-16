import { useWalletAuth } from "@/provider/WalletAuthProvider";

export const Landing = () => {
  const { currentUser, logIn, logOut } = useWalletAuth();

  return (
    <div>
      {!currentUser.loggedIn ? (
        <button onClick={logIn}>Sign In</button>
      ) : (
        <>
          <p>{currentUser.addr}</p>
          <button onClick={logOut}>Sign Out</button>
        </>
      )}
    </div>
  );
};
