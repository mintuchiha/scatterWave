The finite potential well has a probability associated with the particle being found outside the box. The probability of finding a particle outside the box, where the energy of the particle is less than the potential energy is non-zero in this quantum situation. This phenomenon is mathematically explained by the time independent Schrödinger equation given by
$$	E\Psi = \hat{H}\Psi$$
$$ E\Psi(x) = \frac{-\hbar}{2m}\delta^2\Psi(x)+V(x)\Psi(x)$$
where $E$ is the energy of the particle, $H$ is the hamiltonian operator, $\hbar$ is the reduced Planck constant, $m$ is the mass of the particle, $V$ is the potential energy and is the wave function. For the finite potential well the wave function is given by
$$\Psi(x)=
\begin{cases}
	N \sin(kx)~~~ E>V\\
	N\exp(\kappa x)~~~ E<V	
\end{cases}$$
where $k=\sqrt{E-V}$, $\kappa=\sqrt{V-E}$ and $N$ is the normalization factor. For computational purposes, it was necessary to numerically integrate the Schrödinger equation for each energy value to shoot the wave function from left to right. The program offers a graphic interface to the user.

![alt text](https://github.com/mintuchiha/scatterWave/blob/master/ScatterWave_mov.gif "Scatter Wave Animation")