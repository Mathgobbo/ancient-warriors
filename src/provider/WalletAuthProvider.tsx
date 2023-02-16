import * as fcl from "@onflow/fcl";
import { createContext, ReactNode, useContext, useEffect, useState } from "react";

interface IUser {
  loggedIn: boolean;
  addr?: string;
}

interface IWalletAuthContext {
  currentUser: IUser;
  logIn: () => void;
  logOut: () => void;
}

const WalletAuthContext = createContext<IWalletAuthContext>({} as IWalletAuthContext);

export const WalletAuthProvider = ({ children }: { children: ReactNode }) => {
  const [currentUser, setUser] = useState<IUser>({ loggedIn: false, addr: undefined });

  useEffect(() => fcl.currentUser.subscribe(setUser), []);

  const logIn = () => {
    fcl.authenticate();
  };

  const logOut = () => {
    fcl.unauthenticate();
  };

  return <WalletAuthContext.Provider value={{ currentUser, logIn, logOut }}>{children}</WalletAuthContext.Provider>;
};

export const useWalletAuth = () => useContext(WalletAuthContext);
