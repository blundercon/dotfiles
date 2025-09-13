.PHONY: backup bootstrap stow clean

backup:
	./backup.sh

bootstrap:
	./bootstrap.sh

stow:
	cd stow && stow */

clean:
	cd stow && stow -D */
