"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Mail, Lock, User, Phone, Building, AlertCircle, CheckCircle, Loader2 } from "lucide-react";

export default function RegisterPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [alert, setAlert] = useState<{ type: "error" | "success" | "warning"; message: string } | null>(null);
  const [passwordStrength, setPasswordStrength] = useState<{ level: number; text: string; color: string }>({
    level: 0,
    text: "",
    color: ""
  });

  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    companyName: "",
    companySize: "1-10",
    password: "",
    confirmPassword: "",
    terms: false
  });

  // Check password strength
  const checkPasswordStrength = (password: string) => {
    let strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (/[a-z]/.test(password)) strength++;
    if (/[A-Z]/.test(password)) strength++;
    if (/[0-9]/.test(password)) strength++;
    if (/[^a-zA-Z0-9]/.test(password)) strength++;

    if (strength < 3) {
      setPasswordStrength({ level: strength, text: "⚠️ Weak password", color: "text-red-500" });
    } else if (strength < 5) {
      setPasswordStrength({ level: strength, text: "✓ Medium password", color: "text-yellow-500" });
    } else {
      setPasswordStrength({ level: strength, text: "✓✓ Strong password", color: "text-green-500" });
    }
  };

  useEffect(() => {
    if (formData.password) {
      checkPasswordStrength(formData.password);
    } else {
      setPasswordStrength({ level: 0, text: "", color: "" });
    }
  }, [formData.password]);

  const validatePhone = (phone: string) => {
    const cleaned = phone.replace(/[\s()-]/g, "");
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    return phoneRegex.test(cleaned);
  };

  const generateSlug = (name: string) => {
    return name
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9\s-]/g, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-+|-+$/g, "");
  };

  const showAlert = (message: string, type: "error" | "success" | "warning" = "error") => {
    setAlert({ type, message });
    if (type === "success") {
      setTimeout(() => setAlert(null), 5000);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setAlert(null);

    // Validation
    if (formData.name.length < 2) {
      showAlert("Please enter your full name (minimum 2 characters)");
      return;
    }

    if (!formData.email.includes("@")) {
      showAlert("Please enter a valid email address");
      return;
    }

    if (!validatePhone(formData.phone)) {
      showAlert("Please enter a valid phone number with country code (e.g., +1234567890)");
      return;
    }

    if (formData.companyName.length < 2) {
      showAlert("Please enter your company name (minimum 2 characters)");
      return;
    }

    if (formData.password.length < 8) {
      showAlert("Password must be at least 8 characters long");
      return;
    }

    if (!/[A-Z]/.test(formData.password) || !/[a-z]/.test(formData.password) || !/[0-9]/.test(formData.password)) {
      showAlert("Password must contain uppercase, lowercase, and numbers");
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      showAlert("Passwords do not match");
      return;
    }

    if (!formData.terms) {
      showAlert("Please accept the Terms of Service and Privacy Policy");
      return;
    }

    setLoading(true);

    try {
      // Import supabase dynamically (client-side only)
      const { supabase } = await import("../../../lib/supabaseClient");

      console.log("Starting registration process...");

      // Step 1: Create auth user
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: formData.email.toLowerCase().trim(),
        password: formData.password,
        options: {
          data: {
            full_name: formData.name,
            phone: formData.phone,
            company_name: formData.companyName
          },
          emailRedirectTo: `${window.location.origin}/verify-email`
        }
      });

      if (authError) throw authError;
      if (!authData.user) throw new Error("User creation failed");

      const userId = authData.user.id;

      // Step 2: Create client (company) first
      const { data: clientData, error: clientError } = await supabase
        .from("clients")
        .insert([{
          name: formData.companyName,
          is_active: true
        }])
        .select()
        .single();

      if (clientError) throw new Error(`Failed to create organization: ${clientError.message}`);

      const clientId = clientData.id;

      // Step 3: Create global user with client_id
      const { error: globalUserError } = await supabase
        .from("global_users")
        .insert([{
          id: userId,
          email: formData.email.toLowerCase().trim(),
          name: formData.name,
          client_id: clientId,
          role: "admin",
          is_client_owner: true
        }]);

      if (globalUserError) throw new Error(`Failed to create user profile: ${globalUserError.message}`);

      // Update client with primary contact
      await supabase
        .from("clients")
        .update({ primary_contact_id: userId })
        .eq("id", clientId);

      // Step 4: Get SMS Gateway Pro product ID
      const { data: productData, error: productError } = await supabase
        .from("products")
        .select("id")
        .eq("schema_name", "sms_gateway")
        .single();

      if (productError || !productData) throw new Error("SMS Gateway Pro product not found");

      const productId = productData.id;

      // Step 5: Create tenant in sms_gateway schema
      const tenantSlug = generateSlug(formData.companyName);
      const { data: tenantData, error: tenantError } = await supabase
        .from("sms_gateway.tenants")
        .insert([{
          client_id: clientId,
          name: formData.companyName,
          slug: tenantSlug,
          status: "active"
        }])
        .select()
        .single();

      if (tenantError) throw new Error(`Failed to create SMS Gateway tenant: ${tenantError.message}`);

      const tenantId = tenantData.id;

      // Step 6: Link user to tenant as owner
      const { error: memberError } = await supabase
        .from("sms_gateway.tenant_members")
        .insert([{
          tenant_id: tenantId,
          user_id: userId,
          role: "owner"
        }]);

      if (memberError) throw new Error(`Failed to link user to organization: ${memberError.message}`);

      // Step 7: Create user profile in sms_gateway schema
      const { error: profileError } = await supabase
        .from("sms_gateway.users")
        .insert([{
          id: userId,
          email: formData.email.toLowerCase().trim(),
          name: formData.name,
          phone_number: formData.phone,
          tenant_id: tenantId,
          role: "admin"
        }]);

      if (profileError) throw new Error(`Failed to create SMS Gateway profile: ${profileError.message}`);

      // Step 8: Initialize user settings
      await supabase.from("sms_gateway.user_settings").insert([{
        user_id: userId,
        sms_channel: "native",
        theme: "light",
        language: "en",
        notifications_enabled: true
      }]);

      // Step 9: Create product subscription with trial (3 months free - valid for 2025 & 2026 signups)
      const currentYear = new Date().getFullYear();
      const startDate = new Date();
      const endDate = new Date(startDate);
      
      if (currentYear === 2025 || currentYear === 2026) {
        // 3-month free trial
        endDate.setMonth(endDate.getMonth() + 3);

        await supabase.from("product_subscriptions").insert([{
          client_id: clientId,
          product_id: productId,
          subscription_type: "trial",
          status: "active",
          start_date: startDate.toISOString(),
          end_date: endDate.toISOString()
        }]);
      } else {
        // Regular subscription
        endDate.setMonth(endDate.getMonth() + 1);

        await supabase.from("product_subscriptions").insert([{
          client_id: clientId,
          product_id: productId,
          subscription_type: "monthly",
          status: "pending",
          start_date: startDate.toISOString(),
          end_date: endDate.toISOString()
        }]);
      }

      showAlert(
        `✅ Account created successfully! Please check ${formData.email} for a verification link.`,
        "success"
      );

      // Reset form
      setFormData({
        name: "",
        email: "",
        phone: "",
        companyName: "",
        companySize: "1-10",
        password: "",
        confirmPassword: "",
        terms: false
      });

      // Redirect after 3 seconds
      setTimeout(() => {
        router.push("/check-email");
      }, 3000);

    } catch (error: any) {
      console.error("Registration failed:", error);

      let errorMessage = "Registration failed. Please try again.";

      if (error.message.includes("duplicate key") || error.message.includes("already exists")) {
        errorMessage = "❌ An account with this email already exists. Try logging in instead.";
      } else if (error.message.includes("invalid email")) {
        errorMessage = "❌ Invalid email address format.";
      } else if (error.message.includes("weak password")) {
        errorMessage = "❌ Password is too weak. Please use a stronger password.";
      } else if (error.message.includes("network")) {
        errorMessage = "❌ Network error. Please check your internet connection.";
      } else if (error.message) {
        errorMessage = `❌ ${error.message}`;
      }

      showAlert(errorMessage, "error");
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { id, value, type } = e.target;
    setFormData(prev => ({
      ...prev,
      [id]: type === "checkbox" ? (e.target as HTMLInputElement).checked : value
    }));
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-12 px-4">
      <div className="max-w-2xl mx-auto">
        {/* Header */}
        <div className="text-center mb-8">
          <Link href="/" className="inline-block mb-4">
            <h1 className="text-3xl font-bold">
              Lwena <span className="text-amber-500">TechWareAfrica</span>
            </h1>
          </Link>
          <h2 className="text-2xl font-bold text-gray-800 mb-2">Create Your Account</h2>
          <p className="text-gray-600">
            Join SMS Gateway Pro and start your <strong>3-month free trial</strong>
          </p>
        </div>

        {/* Alert */}
        {alert && (
          <div className={`mb-6 p-4 rounded-lg flex items-start gap-3 ${
            alert.type === "error" ? "bg-red-50 border border-red-200 text-red-800" :
            alert.type === "success" ? "bg-green-50 border border-green-200 text-green-800" :
            "bg-yellow-50 border border-yellow-200 text-yellow-800"
          }`}>
            {alert.type === "error" && <AlertCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />}
            {alert.type === "success" && <CheckCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />}
            {alert.type === "warning" && <AlertCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />}
            <span>{alert.message}</span>
          </div>
        )}

        {/* Form */}
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Personal Information */}
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
                <User className="w-5 h-5 text-amber-500" />
                Personal Information
              </h3>

              <div className="space-y-4">
                <div>
                  <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
                    Full Name *
                  </label>
                  <input
                    type="text"
                    id="name"
                    value={formData.name}
                    onChange={handleChange}
                    required
                    minLength={2}
                    placeholder="John Doe"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  />
                  <p className="text-xs text-gray-500 mt-1">Your full name as it should appear in the system</p>
                </div>

                <div>
                  <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                    Email Address *
                  </label>
                  <div className="relative">
                    <Mail className="absolute left-3 top-3.5 w-5 h-5 text-gray-400" />
                    <input
                      type="email"
                      id="email"
                      value={formData.email}
                      onChange={handleChange}
                      required
                      placeholder="john@example.com"
                      className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                    />
                  </div>
                  <p className="text-xs text-gray-500 mt-1">We'll send a verification link to this email</p>
                </div>

                <div>
                  <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-2">
                    Phone Number *
                  </label>
                  <div className="relative">
                    <Phone className="absolute left-3 top-3.5 w-5 h-5 text-gray-400" />
                    <input
                      type="tel"
                      id="phone"
                      value={formData.phone}
                      onChange={handleChange}
                      required
                      placeholder="+1 234 567 8900"
                      pattern="^\+?[1-9]\d{1,14}$"
                      className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                    />
                  </div>
                  <p className="text-xs text-gray-500 mt-1">Include country code (e.g., +1 for US)</p>
                </div>
              </div>
            </div>

            {/* Organization Information */}
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
                <Building className="w-5 h-5 text-amber-500" />
                Organization Information
              </h3>

              <div className="space-y-4">
                <div>
                  <label htmlFor="companyName" className="block text-sm font-medium text-gray-700 mb-2">
                    Company/Organization Name *
                  </label>
                  <input
                    type="text"
                    id="companyName"
                    value={formData.companyName}
                    onChange={handleChange}
                    required
                    minLength={2}
                    placeholder="Acme Corporation"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label htmlFor="companySize" className="block text-sm font-medium text-gray-700 mb-2">
                    Company Size
                  </label>
                  <select
                    id="companySize"
                    value={formData.companySize}
                    onChange={handleChange}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  >
                    <option value="1-10">1-10 employees</option>
                    <option value="11-50">11-50 employees</option>
                    <option value="51-200">51-200 employees</option>
                    <option value="201-1000">201-1000 employees</option>
                    <option value="1000+">1000+ employees</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Security */}
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
                <Lock className="w-5 h-5 text-amber-500" />
                Security
              </h3>

              <div className="space-y-4">
                <div>
                  <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                    Password *
                  </label>
                  <input
                    type="password"
                    id="password"
                    value={formData.password}
                    onChange={handleChange}
                    required
                    minLength={8}
                    placeholder="Minimum 8 characters"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  />
                  {passwordStrength.text && (
                    <p className={`text-sm font-medium mt-2 ${passwordStrength.color}`}>
                      {passwordStrength.text}
                    </p>
                  )}
                  <p className="text-xs text-gray-500 mt-1">
                    At least 8 characters with uppercase, lowercase, and numbers
                  </p>
                </div>

                <div>
                  <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 mb-2">
                    Confirm Password *
                  </label>
                  <input
                    type="password"
                    id="confirmPassword"
                    value={formData.confirmPassword}
                    onChange={handleChange}
                    required
                    minLength={8}
                    placeholder="Re-enter password"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  />
                </div>
              </div>
            </div>

            {/* Terms */}
            <div className="flex items-start gap-3">
              <input
                type="checkbox"
                id="terms"
                checked={formData.terms}
                onChange={handleChange}
                required
                className="mt-1 w-4 h-4 text-amber-500 border-gray-300 rounded focus:ring-amber-500"
              />
              <label htmlFor="terms" className="text-sm text-gray-700">
                I agree to the{" "}
                <Link href="/terms" className="text-amber-600 hover:text-amber-700 underline">
                  Terms of Service
                </Link>{" "}
                and{" "}
                <Link href="/privacy" className="text-amber-600 hover:text-amber-700 underline">
                  Privacy Policy
                </Link>
              </label>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-gradient-to-r from-amber-500 to-orange-600 text-white py-4 rounded-lg font-semibold hover:from-amber-600 hover:to-orange-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {loading ? (
                <>
                  <Loader2 className="w-5 h-5 animate-spin" />
                  Creating your account...
                </>
              ) : (
                "Create Account"
              )}
            </button>
          </form>

          {/* Footer */}
          <div className="mt-6 text-center text-sm text-gray-600">
            Already have an account?{" "}
            <Link href="/login" className="text-amber-600 hover:text-amber-700 font-semibold">
              Sign in
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
