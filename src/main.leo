// The 'token_4554' program.
program token_4554.aleo {
    mapping balance: address => u128;

    record Token{
        owner: address,
        balance: u128
    }

    transition mint(amount: u128) -> Token {
        return Token{
            owner: self.caller,
            balance: amount
        };
    }

    transition transfer(receiver: address, amount: u128, input: Token) -> (Token, Token){
        let difference: u128 = input.balance - amount;
        let ori_owner: Token = Token{
            owner: self.caller,
            balance: difference
        };

        let recipient: Token = Token{
            owner: receiver,
            balance: amount
        };
        return(ori_owner, recipient);
    }

    //internal function, procedure
    // function helper()

    transition transfer_private_to_public(receiver: address, amount: u128, input: Token) -> Token {
        let difference: u128 = input.balance - amount;
        let ori_owner: Token = Token{
            owner: self.caller,
            balance: difference
        };
        return then finalize(receiver, amount);
    }

    //on-chain execution
    finalize transfer_private_to_public(receiver: address, amount: u128){
        let prev_balance: u128 = Mapping::get_or_use(balance, receiver, 0u128); // 0 as default if receiver is empty
        Mapping::set(balance, receiver, prev_balance+amount);
    }

    transition transfer_public(receiver: address, amount: u128){
        return then finalize (self.caller, receiver, amount);
    }

    finalize transfer_public(sender: address, receiver: address, amount: u128){
        let sender_balance: u128 = Mapping::get(balance, sender);
        let difference: u128 = sender_balance - amount;
        Mapping::set(balance, sender, difference);

        let receiver_bal: u128 = Mapping::get(balance, receiver);
        Mapping::set(balance, sender, receiver_bal+amount);
    }

//transfer from public view to private view
    transition transfer_public_to_private(receiver: address, amount: u128)->Token{
        return Token{
            owner: receiver,
            balance: amount
        } then finalize (self.caller, amount);
    }

    finalize transfer_public_to_private(sender: address, amount: u128){
        let prev_bal: u128 = Mapping::get(balance, sender);
        Mapping::set(balance, sender, prev_bal-amount);
    }

    transition join(input: Token, input_two: Token) -> Token{
        return Token{
            owner: self.caller,
            balance: input.balance + input_two.balance
        };
    }
}
